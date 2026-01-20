<?php
header("Content-Type: application/json; charset=utf-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    // preflight
    http_response_code(200);
    exit;
}

// อ่าน input (JSON หรือ form)
$input = json_decode(file_get_contents('php://input'), true);
$data = is_array($input) ? $input : $_POST;

$course_id = isset($data['course_id']) ? (int)$data['course_id'] : 0;
$date      = isset($data['date']) ? trim($data['date']) : '';

if ($course_id <= 0 || $date === '') {
    echo json_encode(['success' => false, 'message' => 'Missing course_id or date']);
    exit;
}

// รวมไฟล์เชื่อมต่อฐานข้อมูลของคุณ
// connect.php ควรประกาศตัวแปร $dsn, $user, $pass, $options
include 'connect.php';
include 'config.php';

try {
    // บังคับให้ PDO โยน exception
    $pdo = new PDO($dsn, $user, $pass, $options);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'DB connect error', 'error' => $e->getMessage()]);
    exit;
}

// helper: สร้างรหัสสุ่ม
function random_password($length = 6) {
    $chars = 'ABCDEFGHJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789';
    $str = '';
    for ($i = 0; $i < $length; $i++) {
        $str .= $chars[random_int(0, strlen($chars) - 1)];
    }
    return $str;
}

// แปลงวันที่และหา weekday index (0=Sun..6=Sat)
try {
    $dateObj = new DateTime($date);
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Invalid date format', 'error' => $e->getMessage()]);
    exit;
}
$qr_date = $dateObj->format('Y-m-d');
$weekdayIndex = (int)$dateObj->format('w');

// หา schedule ตามวันที่ (day_id) ถ้าไม่มีให้ fallback มา schedule ใดๆ ของ course
try {
    $schedStmt = $pdo->prepare("SELECT * FROM `schedule` WHERE course_id = :course_id AND day_id = :day_id LIMIT 1");
    $schedStmt->execute([':course_id' => $course_id, ':day_id' => $weekdayIndex]);
    $schedule = $schedStmt->fetch(PDO::FETCH_ASSOC);

    if (!$schedule) {
        $fallback = $pdo->prepare("SELECT * FROM `schedule` WHERE course_id = :course_id LIMIT 1");
        $fallback->execute([':course_id' => $course_id]);
        $schedule = $fallback->fetch(PDO::FETCH_ASSOC);
        if (!$schedule) {
            echo json_encode(['success' => false, 'message' => 'Schedule not found for this course']);
            exit;
        }
    }
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Schedule lookup failed', 'error' => $e->getMessage()]);
    exit;
}

// function: get or create qr code (atomic-friendly) — ใช้ course_id + qr_date + schedule_id
function getOrCreateQr(PDO $pdo, int $course_id, string $qr_date, array $schedule) {
    // คืนค่าที่เป็น array: [qr_code_id, qr_password]
    // พยายาม INSERT แล้วจับ duplicate error ถ้าเกิดขึ้น SELECT แถวเดิมกลับมา
    $qr_password = random_password(6);
    $qr_hash = password_hash($qr_password . '|' . $course_id . '|' . $qr_date . '|' . ($schedule['schedule_id'] ?? ''), PASSWORD_DEFAULT);

    $schedule_id = $schedule['schedule_id'] ?? null;

    try {
        $insQr = $pdo->prepare("INSERT INTO qr_code (course_id, qr_code_password, qr_code_hash, schedule_id, qr_date)
            VALUES (:course_id, :qr_password, :qr_hash, :schedule_id, :qr_date)");
        $insQr->execute([
            ':course_id' => $course_id,
            ':qr_password' => $qr_password,
            ':qr_hash' => $qr_hash,
            ':schedule_id' => $schedule_id,
            ':qr_date' => $qr_date
        ]);
        $qr_code_id = (int)$pdo->lastInsertId();
        return [$qr_code_id, $qr_password];
    } catch (PDOException $e) {
        // SQLSTATE 23000 = integrity constraint violation (duplicate key)
        if ($e->getCode() === '23000') {
            // ดึงแถวที่มีอยู่โดยใช้ทั้งสามคอลัมน์
            $checkQr = $pdo->prepare("SELECT * FROM qr_code WHERE course_id = :course_id AND qr_date = :qr_date AND schedule_id " . ($schedule_id === null ? "IS NULL" : "= :schedule_id") . " LIMIT 1");
            $params = [':course_id' => $course_id, ':qr_date' => $qr_date];
            if ($schedule_id !== null) {
                $params[':schedule_id'] = $schedule_id;
            }
            $checkQr->execute($params);
            $qr = $checkQr->fetch(PDO::FETCH_ASSOC);
            if ($qr) {
                return [(int)$qr['qr_code_id'], $qr['qr_code_password']];
            } else {
                // ถ้าไม่พบ (แปลก) โยน exception ต่อ
                throw $e;
            }
        } else {
            throw $e;
        }
    }
}

// รับหรือสร้าง qr code
try {
    list($qr_code_id, $qr_password) = getOrCreateQr($pdo, $course_id, $qr_date, $schedule);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'QR creation failed', 'error' => $e->getMessage()]);
    exit;
}

// ตรวจสอบว่ามี attendance อยู่แล้ว (fast path)
try {
    // ให้ section เป็น empty string ถ้า NULL เพื่อให้ unique index ทำงานสอดคล้อง
    $section = isset($schedule['section']) ? (string)$schedule['section'] : '';

    $checkAtt = $pdo->prepare("SELECT * FROM attendance WHERE course_id = :course_id AND day = :day AND section = :section LIMIT 1");
    $checkAtt->execute([
        ':course_id' => $course_id,
        ':day' => $qr_date,
        ':section' => $section
    ]);
    $attendance = $checkAtt->fetch(PDO::FETCH_ASSOC);

    if ($attendance) {
        echo json_encode([
            'success' => true,
            'message' => '',
            'attendance_id' => $attendance['attendance_id'],
            'qr_code_id' => $qr_code_id,
            'qr_password' => $qr_password
        ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
        exit;
    }
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Attendance lookup failed', 'error' => $e->getMessage()]);
    exit;
}

// หากยังไม่มี attendance ให้พยายาม INSERT แบบ atomic (transaction + handle duplicate)
$att_day = $qr_date;
$att_section = $section; // ensure not null

try {
    $pdo->beginTransaction();

    // พยายาม insert attendance ตรงๆ
    $insAtt = $pdo->prepare("INSERT INTO attendance
        (course_id, course_name, day, time, teacher_name, section, class, qr_code_id)
        VALUES (:course_id, :course_name, :day, :time, :teacher_name, :section, :class, :qr_code_id)");
    $insAtt->execute([
        ':course_id' => $course_id,
        ':course_name' => $schedule['course_name'] ?? null,
        ':day' => $att_day,
        ':time' => $schedule['time'] ?? null,
        ':teacher_name' => $schedule['teacher_name'] ?? null,
        ':section' => $att_section,
        ':class' => $schedule['class'] ?? null,
        ':qr_code_id' => $qr_code_id
    ]);
    $attendance_id = (int)$pdo->lastInsertId();

    // ดึง schedule_detail เพื่อสร้าง attendance_detail
    $sdStmt = $pdo->prepare("SELECT * FROM schedule_detail WHERE schedule_id = :schedule_id");
    $sdStmt->execute([':schedule_id' => $schedule['schedule_id']]);
    $details = $sdStmt->fetchAll(PDO::FETCH_ASSOC);

    $insDetail = $pdo->prepare("INSERT INTO attendance_detail
        (attendance_id, user_id, student_id, student_name, time, latitude, longitude, qr_code_id, schedule_id, leave_status, device_id)
        VALUES (:attendance_id, :user_id, :student_id, :student_name, :time, :latitude, :longitude, :qr_code_id, :schedule_id, :leave_status, :device_id)");

    foreach ($details as $d) {
        // ป้องกัน NULL ที่ไม่จำเป็น
        $student_name = $d['user_name'] ?? $d['student_name'] ?? null;
        $insDetail->execute([
            ':attendance_id' => $attendance_id,
            ':user_id' => $d['user_id'] ?? null,
            ':student_id' => $d['student_id'] ?? null,
            ':student_name' => $student_name,
            ':time' => null,
            ':latitude' => null,
            ':longitude' => null,
            ':qr_code_id' => $qr_code_id,
            ':schedule_id' => $schedule['schedule_id'],
            ':leave_status' => '',
            ':device_id' => $d['device_id'] ?? null
        ]);
    }

    $pdo->commit();

    echo json_encode([
        'success' => true,
        'attendance_id' => $attendance_id,
        'qr_code_id' => $qr_code_id,
        'qr_password' => $qr_password,
        'message' => 'Attendance and details created successfully'
    ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    exit;

} catch (PDOException $e) {
    // rollback และจัดการ duplicate key หากเกิดจาก concurrent insert
    $pdo->rollBack();

    if ($e->getCode() === '23000') {
        // มี attendance แล้ว — ดึงข้อมูลและคืนให้ client
        try {
            $checkAtt = $pdo->prepare("SELECT * FROM attendance WHERE course_id = :course_id AND day = :day AND section = :section LIMIT 1");
            $checkAtt->execute([
                ':course_id' => $course_id,
                ':day' => $att_day,
                ':section' => $att_section
            ]);
            $attendance = $checkAtt->fetch(PDO::FETCH_ASSOC);
            if ($attendance) {
                echo json_encode([
                    'success' => true,
                    'message' => 'Attendance already exists (handled duplicate)',
                    'attendance_id' => $attendance['attendance_id'],
                    'qr_code_id' => $qr_code_id,
                    'qr_password' => $qr_password
                ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
                exit;
            } else {
                // ไม่พบจริง ๆ — ส่ง error original
                echo json_encode(['success' => false, 'message' => 'Transaction failed (duplicate detected but no attendance found)', 'error' => $e->getMessage()]);
                exit;
            }
        } catch (PDOException $inner) {
            echo json_encode(['success' => false, 'message' => 'Transaction failed and duplicate handling failed', 'error' => $inner->getMessage()]);
            exit;
        }
    }

    // กรณีอื่น ๆ
    echo json_encode(['success' => false, 'message' => 'Transaction failed', 'error' => $e->getMessage()]);
    exit;
}

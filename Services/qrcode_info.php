<?php
// qrcode.php (attendance version - single student + update)
ini_set('display_errors', 0);
ini_set('log_errors', 1);
ini_set('error_log', __DIR__ . '/error_qrcode.log');
error_reporting(E_ALL);

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include 'connect.php';

$data = json_decode(file_get_contents('php://input'), true);
$qr_code_id = $data['qr_code_id'] ?? null;
$user_id    = $data['user_id'] ?? null;
$day        = $data['day'] ?? null;
$type       = $data['type'] ?? null; // 'save' or 'view'
$time       = $data['time'] ?? null;
$latitude   = $data['latitude'] ?? null;
$longitude  = $data['longitude'] ?? null;
$device_id  = $data['device_id'] ?? null;

if (!$qr_code_id || !$user_id || !$day) {
    echo json_encode(['success' => false, 'message' => 'Missing required data']);
    exit;
}

try {
    $pdo->beginTransaction();

    // ตรวจสอบ QR code
    $stmt = $pdo->prepare("
        SELECT qr.qr_code_id, qr.qr_code_password, qr.course_id, c.course_name, c.teacher_name
        FROM qr_code qr
        JOIN course c ON qr.course_id = c.course_id
        WHERE qr.qr_code_id = :qr
        LIMIT 1
    ");
    $stmt->execute([':qr' => $qr_code_id]);
    $qr = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$qr) {
        echo json_encode(['success' => false, 'message' => 'QR code not found']);
        exit;
    }

    $course_id = (int)$qr['course_id'];

    // หา attendance ของวันนั้น สำหรับ qr_code_id
    $attStmt = $pdo->prepare("
        SELECT attendance_id, course_name, teacher_name, day, time
        FROM attendance
        WHERE course_id = :course_id AND qr_code_id = :qr_code_id AND day = :day
        LIMIT 1
    ");
    $attStmt->execute([
        ':course_id' => $course_id,
        ':qr_code_id' => $qr_code_id,
        ':day'       => $day
    ]);
    $attendance = $attStmt->fetch(PDO::FETCH_ASSOC);

    if (!$attendance) {
        echo json_encode(['success' => false, 'message' => 'Attendance not found for this QR code and day']);
        exit;
    }

    $attendance_id = (int)$attendance['attendance_id'];

    // ดึงข้อมูลนักศึกษาที่ล็อกอิน
    $studentStmt = $pdo->prepare("
        SELECT ad.user_id, ad.student_id, ad.student_name, ad.schedule_id
        FROM attendance_detail ad
        WHERE ad.attendance_id = :attendance_id AND ad.user_id = :user_id
        LIMIT 1
    ");
    $studentStmt->execute([
        ':attendance_id' => $attendance_id,
        ':user_id'       => $user_id
    ]);
    $student = $studentStmt->fetch(PDO::FETCH_ASSOC);

    if (!$student) {
        echo json_encode(['success' => false, 'message' => 'Student not found in attendance']);
        exit;
    }

    // ถ้า type=save ให้บันทึกเวลาและข้อมูลเพิ่มเติม
    if ($type === 'save') {
        // ตรวจสอบว่ามี record อยู่แล้ว
        $checkStmt = $pdo->prepare("
        SELECT * FROM attendance_detail
        WHERE attendance_id = :attendance_id AND user_id = :user_id
        LIMIT 1
    ");
        $checkStmt->execute([
            ':attendance_id' => $attendance_id,
            ':user_id'       => $user_id,
        ]);
        $existing = $checkStmt->fetch(PDO::FETCH_ASSOC);

        if ($existing) {
            // update เวลา
            $updateStmt = $pdo->prepare("
            UPDATE attendance_detail
            SET time = :time
            WHERE attendance_id = :attendance_id AND user_id = :user_id
        ");
            $updateStmt->execute([
                ':time' => $time,
                ':attendance_id' => $attendance_id,
                ':user_id' => $user_id,
            ]);
        }

        $pdo->commit();
        echo json_encode(['success' => true, 'message' => 'บันทึกเวลาเรียบร้อย']);
        exit;
    }

    // ถ้าไม่ save ให้ return student info
    $pdo->commit();
    echo json_encode([
        'success' => true,
        'qr_code_id' => $qr['qr_code_id'],
        'qr_password' => $qr['qr_code_password'],
        'course_name' => $attendance['course_name'],
        'teacher_name' => $attendance['teacher_name'],
        'time' => $attendance['time'],
        'day' => $attendance['day'],
        'students' => [$student], // return list แต่มีคนเดียว
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    if ($pdo->inTransaction()) $pdo->rollBack();
    error_log("DB error in qrcode.php: " . $e->getMessage());
    echo json_encode(['success' => false, 'message' => 'DB error', 'error' => $e->getMessage()]);
}

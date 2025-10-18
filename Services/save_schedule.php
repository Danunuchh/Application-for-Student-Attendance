<?php
ini_set('display_errors', 0);
error_reporting(E_ALL);

include 'connect.php';
include 'config.php';

header('Content-Type: application/json; charset=utf-8');

function json_ok($data)
{
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit;
}

function json_err($code, $msg, $extra = [])
{
    http_response_code($code);
    echo json_encode(array_merge(['success' => false, 'message' => $msg], $extra), JSON_UNESCAPED_UNICODE);
    exit;
}

$input = json_decode(file_get_contents('php://input'), true);

if (!$input || !is_array($input)) {
    json_err(400, 'Invalid JSON');
}

$courseId  = $input['course_id'] ?? 0;
$students  = $input['students'] ?? [];
$type      = $input['type'] ?? '';

if ($courseId <= 0 || empty($students) || $type !== 'insert') {
    json_err(400, 'Missing required fields or invalid type', ['input' => $input]);
}

try {
    // ดึงข้อมูล course และ teacher สำหรับ schedule
    $stCourse = $pdo->prepare("SELECT c.course_name, c.user_id AS teacher_id, u.full_name AS teacher_name, c.day_id, d.day_name
                               FROM course c
                               LEFT JOIN users u ON u.user_id = c.user_id
                               LEFT JOIN day d ON d.day_id = c.day_id
                               WHERE c.course_id = :cid
                               LIMIT 1");
    $stCourse->execute([':cid' => $courseId]);
    $course = $stCourse->fetch();

    if (!$course) {
        json_err(404, 'Course not found');
    }

    // 🔹 ตรวจสอบว่ามี schedule สำหรับ course_id + day_id แล้วหรือยัง
    $stCheck = $pdo->prepare("SELECT schedule_id FROM schedule WHERE course_id = :course_id AND day_id = :day_id LIMIT 1");
    $stCheck->execute([
        ':course_id' => $courseId,
        ':day_id'    => $course['day_id'],
    ]);
    $existing = $stCheck->fetch();

    $pdo->beginTransaction();

    if ($existing) {
        // ถ้ามีแล้ว ใช้ schedule_id เดิม
        $scheduleId = (int)$existing['schedule_id'];
    } else {
        // Insert schedule ใหม่
        $stSchedule = $pdo->prepare("
            INSERT INTO schedule
            (course_id, course_name, teacher_id, teacher_name, day_id, day_name)
            VALUES (:course_id, :course_name, :teacher_id, :teacher_name, :day_id, :day_name)
        ");
        $stSchedule->execute([
            ':course_id'    => $courseId,
            ':course_name'  => $course['course_name'],
            ':teacher_id'   => $course['teacher_id'],
            ':teacher_name' => $course['teacher_name'],
            ':day_id'       => $course['day_id'],
            ':day_name'     => $course['day_name'],
        ]);
        $scheduleId = (int)$pdo->lastInsertId();
    }

    // Insert schedule_detail ถ้ายังไม่มี
    $stDetailCheck = $pdo->prepare("SELECT 1 FROM schedule_detail WHERE schedule_id = :schedule_id AND user_id = :user_id LIMIT 1");
    $stDetail = $pdo->prepare("
        INSERT INTO schedule_detail
        (schedule_id, user_id, user_name, student_id)
        VALUES (:schedule_id, :user_id, :user_name, :student_id)
    ");

    $insertedCount = 0;
    foreach ($students as $s) {
        $stDetailCheck->execute([
            ':schedule_id' => $scheduleId,
            ':user_id'     => $s['user_id'],
        ]);
        if (!$stDetailCheck->fetch()) {
            $stDetail->execute([
                ':schedule_id' => $scheduleId,
                ':user_id'     => $s['user_id'],
                ':user_name'   => $s['user_name'],
                ':student_id'  => $s['student_id'],
            ]);
            $insertedCount++;
        }
    }

    $pdo->commit();

    json_ok([
        'success' => true,
        'schedule_id' => $scheduleId,
        'inserted_students' => $insertedCount,
        'message' => $insertedCount ? 'Inserted successfully' : 'All students already exist'
    ]);
} catch (Throwable $e) {
    $pdo->rollBack();
    json_err(500, 'Insert failed', ['error' => $e->getMessage()]);
}

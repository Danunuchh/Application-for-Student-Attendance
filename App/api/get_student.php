<?php

include 'config.php';
include 'connect.php';

header('Content-Type: application/json; charset=utf-8');

$course_id = $_GET['course_id'] ?? '';

if (empty($course_id)) {
    echo json_encode(['success' => false, 'message' => '❌ ไม่พบค่า course_id']);
    exit;
}

try {
    // 🔹 ตรวจว่านักศึกษาที่ลงวิชานี้ไว้แล้วมีหรือไม่
    $check_sql = "
        SELECT d.user_id
        FROM schedule_detail d
        INNER JOIN schedule s ON s.schedule_id = d.schedule_id
        WHERE s.course_id = :course_id
    ";
    $check_stmt = $pdo->prepare($check_sql);
    $check_stmt->execute(['course_id' => $course_id]);
    $enrolled_students = $check_stmt->fetchAll(PDO::FETCH_COLUMN);

    // 🔹 ดึงนักศึกษาทั้งหมด
    $sql = "
        SELECT *, LEFT(student_id, 2) AS start_year
        FROM users
        WHERE role_id = 'student'
    ";
    $stmt = $pdo->prepare($sql);
    $stmt->execute();
    $students = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // 🔹 ถ้ามีคนลงแล้ว → ตัดออกจากรายชื่อ
    if (!empty($enrolled_students)) {
        $students = array_filter($students, function ($s) use ($enrolled_students) {
            return !in_array($s['user_id'], $enrolled_students);
        });
    }

    echo json_encode([
        'success' => true,
        'students' => array_values($students), // รีเซ็ต key array
    ]);
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => '⚠️ Database error: ' . $e->getMessage(),
    ]);
}

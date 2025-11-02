<?php
// attendance_api.php

ini_set('display_errors', 1);
ini_set('log_errors', 1);
error_reporting(E_ALL);

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST");
header("Access-Control-Allow-Headers: Content-Type");

// รับ input
$input = json_decode(file_get_contents('php://input'), true);
if (!$input) $input = $_POST;

$course_id = $_POST['course_id'] ?? $_GET['course_id'] ?? 0;
$type = $_GET['type'] ?? ($input['type'] ?? 'default'); // รับ type จาก GET หรือ POST
$date = isset($input['date']) ? date('Y-m-d', strtotime($input['date'])) : date('Y-m-d');

if ($course_id === 0) {
    http_response_code(400);
    echo json_encode(['error' => 'Missing course_id']);
    exit;
}

// เชื่อมต่อฐานข้อมูล
include 'connect.php'; // ต้องแน่ใจว่า connect.php สร้าง $pdo

try {
    if ($type === 'student') {
        // Query สำหรับ student (เช็คชื่อเฉพาะนักเรียน)
        $sql = "
            SELECT 
                ad.attendance_detail_id,
                ad.user_id,
                ad.student_id,
                ad.student_name,
                ad.time AS attendance_time,
                ad.leave_status
            FROM attendance_detail ad
            JOIN attendance a ON ad.attendance_id = a.attendance_id
            WHERE a.course_id = :course_id
            ORDER BY ad.student_name
        ";
        $stmt = $pdo->prepare($sql);
        $stmt->execute(['course_id' => $course_id]);
    } else {
        // Query default หรือ type อื่นๆ
        $sql = "
            SELECT 
                ad.attendance_detail_id,
                ad.user_id,
                ad.student_id,
                ad.student_name,
                ad.time AS attendance_time,
                ad.latitude,
                ad.longitude,
                ad.qr_code_id,
                ad.schedule_id,
                ad.leave_status,
                ad.device_id,
                a.attendance_id,
                a.course_id,
                a.course_name,
                a.day,
                a.time AS class_time,
                a.teacher_name,
                a.section,
                a.class
            FROM attendance_detail ad
            JOIN attendance a ON ad.attendance_id = a.attendance_id
            WHERE a.course_id = :course_id
              AND a.day = :date
            ORDER BY ad.student_name
        ";
        $stmt = $pdo->prepare($sql);
        $stmt->execute(['course_id' => $course_id, 'date' => $date]);
    }

    $data = $stmt->fetchAll();
    echo json_encode(['data' => $data], JSON_UNESCAPED_UNICODE);
} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Query failed', 'message' => $e->getMessage()]);
}

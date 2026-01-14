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
// รับข้อมูลจาก JSON POST หรือ fallback เป็น x-www-form-urlencoded
date_default_timezone_set('Asia/Bangkok');

// รับข้อมูลจาก JSON POST หรือ fallback เป็น x-www-form-urlencoded
$input = json_decode(file_get_contents('php://input'), true);
if (!$input) $input = $_POST;

// รับค่าจาก POST/JSON
$course_id = $input['course_id'] ?? $_GET['course_id'] ?? 0;
$type      = $input['type'] ?? $_GET['type'] ?? 'default';
$date      = $input['date'] ?? ($_GET['date'] ?? date('Y-m-d')); // ❗ ไม่ใช้ strtotime()
$user_id   = $input['user_id'] ?? $_GET['user_id'] ?? 0;

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
            a.day,
            ad.time AS attendance_time,
            ad.leave_status
        FROM attendance_detail ad
        JOIN attendance a ON ad.attendance_id = a.attendance_id
        WHERE a.course_id = :course_id
          AND ad.user_id = :user_id
    ";

        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            'course_id' => $course_id,
            'user_id' => $user_id,
        ]);
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
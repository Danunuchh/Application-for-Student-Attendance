<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Accept');

// จัดการ OPTIONS request สำหรับ CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// ตรวจสอบว่าเป็น POST request
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Method not allowed'
    ]);
    exit;
}

try {
    // รับข้อมูล JSON จาก Flutter
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    // ตรวจสอบข้อมูลที่จำเป็น
    if (!$data) {
        throw new Exception('Invalid JSON data');
    }

    $required_fields = ['prefix', 'full_name', 'gender', 'email', 'password'];
    foreach ($required_fields as $field) {
        if (empty($data[$field])) {
            throw new Exception("Field '$field' is required");
        }
    }

    // ตรวจสอบรูปแบบอีเมล
    if (!filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
        throw new Exception('รูปแบบอีเมลไม่ถูกต้อง');
    }

    // การเชื่อมต่อฐานข้อมูล
    $host = 'db';
    $dbname = 'Application_attendance';
    $username = 'Admin';
    $password = 'Password';

    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // ตรวจสอบว่าอีเมลซ้ำหรือไม่
    $check_stmt = $pdo->prepare("SELECT COUNT(*) FROM users WHERE email = ?");
    $check_stmt->execute([$data['email']]);

    if ($check_stmt->fetchColumn() > 0) {
        throw new Exception('อีเมลนี้ถูกใช้แล้ว');
    }

    // เข้ารหัสรหัสผ่าน
    $hashed_password = password_hash($data['password'], PASSWORD_DEFAULT);

    // เตรียม SQL สำหรับบันทึกข้อมูล
    $stmt = $pdo->prepare("
        INSERT INTO users (prefix , full_name, gender , email, hash_password, created_at) 
        VALUES (?, ?, ?, ?, ?, NOW())
    ");

    // บันทึกข้อมูล
    $stmt->execute([
        $data['prefix'],
        $data['full_name'],
        $data['gender'],
        $data['email'],
        $hashed_password
    ]);

    // ส่งผลลัพธ์กลับไป
    echo json_encode([
        'success' => true,
        'message' => 'สมัครสมาชิกสำเร็จ',
        'user_id' => $pdo->lastInsertId()
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage()
    ]);
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
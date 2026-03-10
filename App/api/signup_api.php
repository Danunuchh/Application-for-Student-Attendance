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

    if (!$data) {
        throw new Exception('Invalid JSON data');
    }

    // ===== ตรวจสอบข้อมูลที่จำเป็น (ไม่ต้องมี role) =====
    $required_fields = ['prefix', 'full_name', 'email', 'password'];
    foreach ($required_fields as $field) {
        if (empty($data[$field])) {
            throw new Exception("Field '$field' is required");
        }
    }

    // ===== ตรวจสอบรูปแบบอีเมล และแยก role จากอีเมล =====
    $email = trim($data['email']);
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        throw new Exception('รูปแบบอีเมลไม่ถูกต้อง');
    }

    //ฟังก์ชันในการแยกรหัสนักศึกษาจากอีเมลที่ลงทะเบียน
    $student_id = trim($data['email']);
    $student_id = explode('@', $student_id)[0];
    if ($student_id >= 99999999) {     
        $student_id = '';       //ดักรหัสของอาจารย์ให้เป็นค่าว่าง
    }

    // แยก local part และ domain (ไม่สนใจตัวพิมพ์ใหญ่เล็ก)
    $emailLower = strtolower($email);
    [$local, $domain] = explode('@', $emailLower, 2);

    // ต้องเป็นโดเมน kmitl.ac.th เท่านั้น
    if ($domain !== 'kmitl.ac.th') {
        throw new Exception('กรุณาใช้อีเมลโดเมน @kmitl.ac.th');
    }

    // นักศึกษา: local เป็นตัวเลขล้วน (เช่น 6407xxxx)
    // อาจารย์: local เป็นตัวอักษร a-z และอาจมีจุดคั่น (เช่น somchai หรือ somchai.s)
    if (preg_match('/^\d+$/', $local)) {
        $role = 'student';
    } elseif (preg_match('/^[a-z]+(?:\.[a-z]+)*$/', $local)) {
        $role = 'teacher';
    } else {
        // กันกรณีรูปแบบอื่น ๆ ที่ไม่แน่ใจ
        throw new Exception('อีเมลนี้ไม่ตรงตามรูปแบบนักศึกษา/อาจารย์ของ KMITL');
    }

    // // (ออปชัน) ตรวจสอบความยาวรหัสผ่านขั้นต่ำ
    // if (strlen($data['password']) <= 6) {
    //     throw new Exception('รหัสผ่านควรมีความยาวอย่างน้อย 6 ตัวอักษร');
    // }

    // ===== การเชื่อมต่อฐานข้อมูล =====
    $host = 'db';
    $dbname = 'Application_attendance';
    $username = 'Admin';
    $password = 'Password';

    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // ตรวจสอบว่าอีเมลซ้ำหรือไม่
    $check_stmt = $pdo->prepare("SELECT COUNT(*) FROM users WHERE email = ?");
    $check_stmt->execute([$email]);
    if ($check_stmt->fetchColumn() > 0) {
        throw new Exception('อีเมลนี้ถูกใช้แล้ว');
    }

    // เข้ารหัสรหัสผ่าน
    $hashed_password = password_hash($data['password'], PASSWORD_DEFAULT);

    // ===== บันทึกข้อมูล (role มาจากการตรวจอีเมล ไม่รับจากผู้ใช้) =====
    $stmt = $pdo->prepare("
        INSERT INTO users (prefix, full_name, email, student_id, role_id, hash_password, created_at)
        VALUES (?, ?, ?, ?, ?, ?, NOW())
    ");

    $stmt->execute([
        $data['prefix'],
        $data['full_name'],
        $email,
        $student_id,
        $role,               // ใช้ค่า role ที่ตรวจได้จากอีเมล
        $hashed_password
    ]);

    echo json_encode([
        'success' => true,
        'message' => 'สมัครสมาชิกสำเร็จ',
        'role'    => $role,
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

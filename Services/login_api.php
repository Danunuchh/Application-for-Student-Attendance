<?php
// login_api.php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *'); // ปรับให้เป็นโดเมนแอปจริงในโปรดักชัน
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Accept');

// CORS preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// จำกัดให้เป็น POST เท่านั้น
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

try {
    // อ่าน JSON จาก body
    $raw = file_get_contents('php://input');
    $data = json_decode($raw, true);

    if (!$data) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Invalid JSON data']);
        exit;
    }

    // ตรวจฟิลด์ที่จำเป็น
    $email = isset($data['email']) ? trim($data['email']) : '';
    $password = isset($data['password']) ? (string)$data['password'] : '';

    // อีเมลสำหรับแอดมินแบบ Hardcode
    $admin = 'Admin' ;
    $superuser = 'Superuser';

    if ($email ===  $admin || $password === $superuser) {
        $admin = 'admin' ;
        echo json_encode([
        'success' => true,
        'message' => 'เข้าสู่ระบบสำเร็จ',
        'user_id' => 0,
        'role_id' => $admin,       // 'student' หรือ 'teacher'
        // เพิ่มเติมได้ เช่น ชื่อเต็ม
        'full_name' => $admin ?? null,
        'email'  => $admin,
        ]);
        exit;
    }


    if ($email === '' || $password === '') {
        http_response_code(422);
        echo json_encode(['success' => false, 'message' => 'กรุณากรอกอีเมลและรหัสผ่าน']);
        exit;
    }

    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        http_response_code(422);
        echo json_encode(['success' => false, 'message' => 'รูปแบบอีเมลไม่ถูกต้อง']);
        exit;
    }

    // ===== ตั้งค่าการเชื่อมต่อฐานข้อมูล =====
    $host = 'db';                       // ปรับให้ตรงกับของคุณ
    $dbname = 'Application_attendance'; // ปรับให้ตรงกับของคุณ
    $username = 'Admin';                // ปรับให้ตรงกับของคุณ
    $password_db = 'Password';          // ปรับให้ตรงกับของคุณ

    $pdo = new PDO(
        "mysql:host=$host;dbname=$dbname;charset=utf8mb4",
        $username,
        $password_db,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]
    );

    // ค้นหาผู้ใช้ตามอีเมล
    $stmt = $pdo->prepare("SELECT user_id, email, role_id, hash_password, full_name FROM users WHERE email = ? LIMIT 1");
    $stmt->execute([strtolower($email)]);
    $user = $stmt->fetch();

    // ไม่พบอีเมล
    if (!$user) {
        // ใช้ 401 เพื่อสื่อว่า credential ไม่ถูกต้อง
        http_response_code(401);
        echo json_encode(['success' => false, 'message' => 'อีเมลหรือรหัสผ่านไม่ถูกต้อง']);
        exit;
    }

    // ตรวจรหัสผ่าน
    if (!password_verify($password, $user['hash_password'])) {
        http_response_code(401);
        echo json_encode(['success' => false, 'message' => 'อีเมลหรือรหัสผ่านไม่ถูกต้อง']);
        exit;
    }

    // ผ่านการตรวจสอบทั้งหมด — ตอบกลับข้อมูลที่แอปรอใช้
    echo json_encode([
        'success' => true,
        'message' => 'เข้าสู่ระบบสำเร็จ',
        'user_id' => $user['user_id'],
        'role_id'    => $user['role_id'],       // 'student' หรือ 'teacher'
        // เพิ่มเติมได้ เช่น ชื่อเต็ม
        'full_name' => $user['full_name'] ?? null,
        'email'  => $user['email'],
    ]);
} catch (PDOException $e) {
    // ซ่อนรายละเอียดในโปรดักชัน
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Database error']);
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}

<?php
include 'config.php';
header('Content-Type: application/json; charset=utf-8');

$data = json_decode(file_get_contents('php://input'), true);
$email = strtolower(trim($data['email'] ?? ''));
$newPassword = $data['new_password'] ?? '';

if (strlen($newPassword) < 6) {
    http_response_code(422);
    echo json_encode(['success' => false, 'message' => 'รหัสผ่านต้องอย่างน้อย 6 ตัว']);
    exit;
}

$hashPassword = password_hash($newPassword, PASSWORD_DEFAULT);

$pdo = new PDO(
    "mysql:host=db;dbname=Application_attendance;charset=utf8mb4",
    'Admin',
    'Password',
    [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
);

// อัปเดตรหัสผ่าน + ล้าง OTP
$stmt = $pdo->prepare(
    "UPDATE users 
     SET hash_password = ?, reset_otp = NULL, reset_expire = NULL
     WHERE email = ?"
);
$stmt->execute([$hashPassword, $email]);

echo json_encode([
    'success' => true,
    'message' => 'เปลี่ยนรหัสผ่านเรียบร้อยแล้ว'
]);

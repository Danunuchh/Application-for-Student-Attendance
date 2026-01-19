<?php
include 'config.php';
header('Content-Type: application/json; charset=utf-8');

$data = json_decode(file_get_contents('php://input'), true);
$email = strtolower(trim($data['email'] ?? ''));
$otp = trim($data['otp'] ?? '');

$pdo = new PDO(
    "mysql:host=db;dbname=Application_attendance;charset=utf8mb4",
    'Admin',
    'Password',
    [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
);

$stmt = $pdo->prepare(
    "SELECT reset_otp, reset_expire FROM users WHERE email = ?"
);
$stmt->execute([$email]);
$user = $stmt->fetch();

if (
    !$user ||
    !password_verify($otp, $user['reset_otp']) ||
    strtotime($user['reset_expire']) < time()
) {
    http_response_code(401);
    echo json_encode(['success' => false, 'message' => 'OTP ไม่ถูกต้องหรือหมดอายุ']);
    exit;
}

echo json_encode([
    'success' => true,
    'message' => 'OTP ถูกต้อง'
]);

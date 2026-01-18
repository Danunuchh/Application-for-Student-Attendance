<?php

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');

include 'config.php';

// ===== PHPMailer (manual) =====
require __DIR__ . '/PHPMailer-master/src/Exception.php';
require __DIR__ . '/PHPMailer-master/src/PHPMailer.php';
require __DIR__ . '/PHPMailer-master/src/SMTP.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

// ===== METHOD =====
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

// ===== INPUT =====
$data = json_decode(file_get_contents('php://input'), true);
$email = strtolower(trim($data['email'] ?? ''));

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(422);
    echo json_encode(['success' => false, 'message' => 'อีเมลไม่ถูกต้อง']);
    exit;
}

// ===== DB =====
$pdo = new PDO(
    "mysql:host=db;dbname=Application_attendance;charset=utf8mb4",
    'Admin',
    'Password',
    [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
);

// ตรวจอีเมล
$stmt = $pdo->prepare("SELECT user_id FROM users WHERE email = ?");
$stmt->execute([$email]);
$user = $stmt->fetch();

if (!$user) {
    http_response_code(404);
    echo json_encode(['success' => false, 'message' => 'ไม่พบอีเมลนี้ในระบบ']);
    exit;
}

// ===== OTP =====
$otp = rand(100000, 999999);
$hashOtp = password_hash($otp, PASSWORD_DEFAULT);
$expire = date("Y-m-d H:i:s", strtotime("+10 minutes"));

$stmt = $pdo->prepare(
    "UPDATE users SET reset_otp = ?, reset_expire = ? WHERE email = ?"
);
$stmt->execute([$hashOtp, $expire, $email]);

// ===== SEND MAIL =====
$mail = new PHPMailer(true);

try {
    $mail->isSMTP();
    $mail->Host = MAIL_HOST;
    $mail->SMTPAuth = true;
    $mail->Username = MAIL_USERNAME;
    $mail->Password = MAIL_PASSWORD;
    $mail->SMTPSecure = 'tls';
    $mail->Port = MAIL_PORT;

    $mail->CharSet = 'UTF-8';
    $mail->setFrom(MAIL_FROM, MAIL_FROM_NAME);
    $mail->addAddress($email);

    $mail->isHTML(true);
    $mail->Subject = 'รหัสยืนยันเปลี่ยนรหัสผ่าน';
    $mail->Body = "
        <h2>OTP สำหรับเปลี่ยนรหัสผ่าน</h2>
        <h1>$otp</h1>
        <p>รหัสนี้มีอายุ 10 นาที</p>
    ";

    $mail->send();

    echo json_encode([
        'success' => true,
        'message' => 'ส่งรหัสยืนยันไปที่อีเมลแล้ว'
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'ส่งอีเมลไม่สำเร็จ'
        // 'error' => $mail->ErrorInfo
    ]);
}

<?php
// connect.php
$host = 'db';                      // ถ้าใช้ Docker service name = db (แก้ตามจริง)
$db   = 'Application_attendance';  // แก้ให้ตรงฐานข้อมูลจริง
$user = 'Admin';                   // แก้ให้ตรง user จริง
$pass = 'Password';                // แก้ให้ตรงรหัสจริง

$dsn  = "mysql:host=$host;dbname=$db;charset=utf8mb4";
$options = [
  PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
  PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
];

try {
  $pdo = new PDO($dsn, $user, $pass, $options);
} catch (Throwable $e) {
  http_response_code(500);
  header('Content-Type: application/json; charset=utf-8');
  echo json_encode([
    'success' => false,
    'message' => 'Database connection failed',
    'error'   => $e->getMessage(),   // ช่วย debug; ผลจริงจะตัดทิ้งได้
  ], JSON_UNESCAPED_UNICODE);
  exit;
}

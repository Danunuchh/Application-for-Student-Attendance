<?php
// connect.php
declare(strict_types=1);

// Database config - แก้ให้ตรงกับ environment ของคุณ
$host = 'db';                      // Docker service name; ถ้าไม่ใช้ docker อาจเป็น '127.0.0.1' หรือ '192.168.0.111'
$db   = 'Application_attendance';
$user = 'Admin';
$pass = 'Password';
$port = 3306; // ถ้าตั้งพอร์ตอื่นให้แก้

$dsn = "mysql:host={$host};port={$port};dbname={$db};charset=utf8mb4";

$options = [
  PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
  PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
  PDO::ATTR_EMULATE_PREPARES   => false, // ปิด emulate เพื่อใช้ native prepares
];

try {
  $pdo = new PDO($dsn, $user, $pass, $options);
} catch (Throwable $e) {
  // Log error (ไฟล์ log ของ server) แต่ไม่ควรโชว์รายละเอียดให้ client ใน production
  error_log('DB connection failed: ' . $e->getMessage());

  // สำหรับการพัฒนา อาจส่งข้อความช่วย debug แต่ remove หรือซ่อนใน production
  http_response_code(500);
  header('Content-Type: application/json; charset=utf-8');
  echo json_encode([
    'success' => false,
    'message' => 'Database connection failed',
    'error'   => $e->getMessage(), // ลบหรือเปลี่ยนเมื่อขึ้น production
  ], JSON_UNESCAPED_UNICODE);
  exit;
}

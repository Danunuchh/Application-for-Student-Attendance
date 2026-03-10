<?php
include 'config.php';

$token = $_GET['token'] ?? '';

$pdo = new PDO(
    "mysql:host=db;dbname=Application_attendance;charset=utf8mb4",
    'Admin',
    'Password',
    [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
);

$status = '';
$message = '';

if (!$token) {
    $status = 'error';
    $message = 'ลิงก์ไม่ถูกต้อง';
} else {
    $stmt = $pdo->prepare("
        SELECT user_id FROM users 
        WHERE verify_token = ?
        AND verify_expire > NOW()
        AND is_verified = 0
    ");
    $stmt->execute([$token]);
    $user = $stmt->fetch();

    if (!$user) {
        $status = 'error';
        $message = 'ลิงก์ไม่ถูกต้องหรือหมดอายุ';
    } else {
        $stmt = $pdo->prepare("
            UPDATE users 
            SET is_verified = 1,
                verify_token = NULL,
                verify_expire = NULL
            WHERE user_id = ?
        ");
        $stmt->execute([$user['user_id']]);

        $status = 'success';
        $message = 'ยืนยันอีเมลสำเร็จ สามารถเข้าสู่ระบบได้แล้ว';
    }
}
?>
<!DOCTYPE html>
<html lang="th">
<head>
<meta charset="UTF-8">
<title>ยืนยันอีเมล</title>
<style>
body {
    font-family: Arial, sans-serif;
    background: #f6f6f6;
}
.box {
    max-width: 500px;
    margin: 80px auto;
    background: #fff;
    padding: 30px;
    border-radius: 10px;
    text-align: center;
}
.success {
    color: #2ecc71;
}
.error {
    color: #e74c3c;
}
.btn {
    display: inline-block;
    margin-top: 20px;
    padding: 10px 20px;
    background: #3498db;
    color: #fff;
    text-decoration: none;
    border-radius: 6px;
}
</style>
</head>
<body>

<div class="box">
    <h2 class="<?= $status ?>">
        <?= $status === 'success' ? '✅ สำเร็จ' : '❌ เกิดข้อผิดพลาด' ?>
    </h2>

    <p><?= htmlspecialchars($message) ?></p>

    <?php if ($status === 'success'): ?>
        <a href="172.16.8.230:8081" class="btn">ไปหน้าเข้าสู่ระบบ</a>
    <?php endif; ?>
</div>

</body>
</html>

<?php
// api/profile.php
// Single endpoint: type=show | type=update
// NOTE: in production, authenticate (Session/JWT) and use server-side user_id.

declare(strict_types=1);

// --- error handling: don't display to client, log instead ---
ini_set('display_errors', '0');
ini_set('log_errors', '1');
error_reporting(E_ALL);

// --- CORS & JSON header (ส่งก่อน output ใด ๆ) ---
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *'); // เปลี่ยนเป็นโดเมนจริงใน production
header('Access-Control-Allow-Methods: GET, POST, PUT, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    // preflight response
    http_response_code(200);
    exit;
}

// --- include DB connection ---
// connect.php ต้องเซ็ต $pdo เป็น PDO instance และตั้ง charset เป็น utf8mb4
// ตัวอย่าง connect.php ควรมีลักษณะ:
// $pdo = new PDO('mysql:host=localhost;dbname=xxx;charset=utf8mb4', $user, $pass, $opts);
// $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
require_once __DIR__ . '/connect.php';
if (!isset($pdo) || !$pdo instanceof PDO) {
    error_log('connect.php did not provide $pdo');
    http_response_code(500);
    echo json_encode(['success'=>false,'message'=>'Database not initialized']);
    exit;
}

function respond(int $code, array $payload): void {
    http_response_code($code);
    echo json_encode($payload, JSON_UNESCAPED_UNICODE);
    exit;
}

function json_input(): array {
    $raw = file_get_contents('php://input');
    if ($raw === false || $raw === '') return [];
    $data = json_decode($raw, true);
    return is_array($data) ? $data : [];
}

function split_full_name(string $full): array {
    $full = trim(preg_replace('/\s+/', ' ', $full));
    if ($full === '') return ['firstName'=>'', 'lastName'=>''];
    $parts = explode(' ', $full);
    if (count($parts) === 1) return ['firstName'=>$parts[0], 'lastName'=>''];
    $last = array_pop($parts);
    $first = implode(' ', $parts);
    return ['firstName'=>$first, 'lastName'=>$last];
}

// ---------- Router ----------
$method = $_SERVER['REQUEST_METHOD'];
$input  = ($method === 'GET') ? $_GET : json_input();
$type   = isset($input['type']) ? strtolower(trim((string)$input['type'])) : 'show';

// ---------- TYPE: SHOW ----------
if ($type === 'show') {
    $userId = isset($input['user_id']) ? (int)$input['user_id'] : 0;
    if ($userId <= 0) {
        respond(400, ['success'=>false, 'message'=>'Missing or invalid user_id']);
    }

    try {
        $stmt = $pdo->prepare("
            SELECT user_id, full_name, email, phone_number, address,
                   profile_attachment, role_id, student_id
            FROM users
            WHERE user_id = :id
            LIMIT 1
        ");
        $stmt->execute([':id' => $userId]);
        $u = $stmt->fetch(PDO::FETCH_ASSOC);
    } catch (Throwable $e) {
        error_log("DB error in profile show: " . $e->getMessage());
        respond(500, ['success'=>false, 'message'=>'Database error']);
    }

    if (!$u) {
        respond(404, ['success'=>false, 'message'=>'User not found']);
    }

    $split = split_full_name((string)($u['full_name'] ?? ''));
    $data = [
        'id'                => (string)$u['user_id'],
        'fullName'          => $u['full_name'] ?? '',
        'firstName'         => $split['firstName'],
        'lastName'          => $split['lastName'],
        'email'             => $u['email'] ?? '',
        'phone'             => $u['phone_number'] ?? '',
        'address'           => $u['address'] ?? '',
        'role'              => $u['role_id'] ?? '',
        'profileAttachment' => $u['profile_attachment'] ?? '',
        'studentId'         => $u['student_id'] ?? '',
    ];
    respond(200, ['success'=>true, 'data'=>$data]);
}

// ---------- TYPE: UPDATE ----------
if ($type === 'update') {
    if (!in_array($method, ['POST','PUT'], true)) {
        respond(405, ['success'=>false, 'message'=>'Use POST or PUT for update']);
    }

    $userId = isset($input['id']) ? (int)$input['id'] : 0;
    if ($userId <= 0) {
        respond(400, ['success'=>false, 'message'=>'Invalid user_id']);
    }

    $email     = trim((string)($input['email'] ?? ''));
    $firstName = trim((string)($input['firstName'] ?? ''));
    $lastName  = trim((string)($input['lastName'] ?? ''));
    $phone     = trim((string)($input['phone'] ?? ''));
    $address   = trim((string)($input['address'] ?? ''));
    $studentId = array_key_exists('studentId', $input) ? trim((string)$input['studentId']) : null;

    if ($email !== '' && !filter_var($email, FILTER_VALIDATE_EMAIL)) {
        respond(422, ['success'=>false, 'message'=>'Invalid email format']);
    }

    // Fetch current row to keep missing fields
    try {
        $stmt = $pdo->prepare("SELECT full_name, email, phone_number, address, student_id FROM users WHERE user_id = :id LIMIT 1");
        $stmt->execute([':id' => $userId]);
        $current = $stmt->fetch(PDO::FETCH_ASSOC);
    } catch (Throwable $e) {
        error_log("DB error fetch current user: " . $e->getMessage());
        respond(500, ['success'=>false, 'message'=>'Database error']);
    }

    if (!$current) {
        respond(404, ['success'=>false, 'message'=>'User not found']);
    }

    $fullName = trim($firstName . ' ' . $lastName);
    if ($fullName === '' && !empty($current['full_name'])) $fullName = $current['full_name'];
    if ($email === '' && !empty($current['email'])) $email = $current['email'];
    if ($phone === '' && !empty($current['phone_number'])) $phone = $current['phone_number'];
    if ($address === '' && !empty($current['address'])) $address = $current['address'];
    if ($studentId === null) $studentId = $current['student_id'];

    try {
        $stmt = $pdo->prepare("
            UPDATE users SET
              full_name    = :full_name,
              email        = :email,
              phone_number = :phone,
              address      = :address,
              student_id   = :student_id
            WHERE user_id = :user_id
            LIMIT 1
        ");
        $stmt->execute([
            ':full_name'  => $fullName,
            ':email'      => $email,
            ':phone'      => $phone,
            ':address'    => $address,
            ':student_id' => $studentId,
            ':user_id'    => $userId,
        ]);
        respond(200, ['success'=>true, 'message'=>'Profile updated']);
    } catch (Throwable $e) {
        error_log("DB error update user: " . $e->getMessage());
        respond(500, ['success'=>false, 'message'=>'Update failed']);
    }
}

// unknown type
respond(400, ['success'=>false, 'message'=>'Unknown type. Use type=show or type=update']);

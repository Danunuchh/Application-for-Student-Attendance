<?php
// api/profile.php
// -------------------------------
// Single endpoint for:
//   - Show profile:  type=show   (GET หรือ POST JSON ก็ได้)
//   - Update profile: type=update (POST/PUT JSON)
// ใช้กับตาราง users (คอลัมน์ตามที่คุณให้มา)
//
// NOTE: ในโปรดักชัน ควรยืนยันตัวตนด้วย Session/JWT แล้วใช้ user_id จากฝั่ง server

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *'); // แนะนำระบุโดเมนจริงในโปรดักชัน
header('Access-Control-Allow-Methods: GET, POST, PUT, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') exit;

include 'connect.php';
function respond(int $code, array $payload) {
  http_response_code($code);
  echo json_encode($payload, JSON_UNESCAPED_UNICODE);
  exit;
}
function json_input(): array {
  $raw = file_get_contents('php://input');
  $data = json_decode($raw, true);
  return is_array($data) ? $data : [];
}


// ---------- Router ----------
$method = $_SERVER['REQUEST_METHOD'];
$input  = ($method === 'GET') ? $_GET : json_input(); // อนุญาต GET (query) และ POST/PUT (JSON)
$type   = isset($input['type']) ? strtolower(trim($input['type'])) : 'show';

// ---------- Utils ----------
/** แบ่ง firstName/lastName จาก full_name (เดาระยะง่าย ๆ) */
function split_full_name(string $full): array {
  $full = trim(preg_replace('/\s+/', ' ', $full));
  if ($full === '') return ['firstName'=>'', 'lastName'=>''];
  $parts = explode(' ', $full);
  if (count($parts) === 1) return ['firstName'=>$parts[0], 'lastName'=>''];
  $last = array_pop($parts);
  $first = implode(' ', $parts);
  return ['firstName'=>$first, 'lastName'=>$last];
}

// =====================================================
// TYPE: SHOW  (GET /api/profile.php?type=show&user_id=...)
// =====================================================
if ($type === 'show') {
  $userId = isset($input['user_id']) ? (int)$input['user_id'] : 0;
  if ($userId <= 0) {
    respond(400, ['success'=>false, 'message'=>'Missing user_id']);
  }

  $stmt = $pdo->prepare("
    SELECT user_id, full_name, email, phone_number, address,
           profile_attachment, role_id, student_id
    FROM users
    WHERE user_id = :id
    LIMIT 1
  ");
  $stmt->execute([':id'=>$userId]);
  $u = $stmt->fetch();
  if (!$u) {
    respond(404, ['success'=>false, 'message'=>'User not found']);
  }

  $split = split_full_name($u['full_name'] ?? '');
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

// =====================================================
// TYPE: UPDATE (POST/PUT JSON -> /api/profile.php { type:"update", ...})
// =====================================================
if ($type === 'update') {
  if (!in_array($method, ['POST','PUT'])) {
    respond(405, ['success'=>false, 'message'=>'Use POST or PUT for update']);
  }

  $userId = isset($input['id']) ? (int)$input['id'] : 0;
  if ($userId <= 0) {
    respond(400, ['success'=>false, 'message'=>'Invalid user_id']);
  }

  $email     = trim($input['email'] ?? '');
  $firstName = trim($input['firstName'] ?? '');
  $lastName  = trim($input['lastName'] ?? '');
  $phone     = trim($input['phone'] ?? '');
  $address   = trim($input['address'] ?? '');
  $studentId = isset($input['studentId'])   ? trim($input['studentId'])   : null;
  $teacherId = isset($input['teacherCode']) ? trim($input['teacherCode']) : null;

  if ($email !== '' && !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    respond(422, ['success'=>false, 'message'=>'Invalid email format']);
  }
  $fullName = trim($firstName . ' ' . $lastName);
  // ถ้าไม่ส่ง first/last มา แปลว่าอาจอยากคงค่าเดิม → จะดึงจาก DB ก่อนแล้วค่อยอัปเดตบางฟิลด์
  $stmt = $pdo->prepare("SELECT full_name, email, phone_number, address, student_id FROM users WHERE user_id = :id LIMIT 1");
  $stmt->execute([':id'=>$userId]);
  $current = $stmt->fetch();
  if (!$current) {
    respond(404, ['success'=>false, 'message'=>'User not found']);
  }

  // ถ้าไม่ได้ส่งค่าใหม่มา ให้คงค่าเดิม
  if ($fullName === '' && !empty($current['full_name'])) $fullName = $current['full_name'];
  if ($email   === '' && !empty($current['email'])) $email = $current['email'];
  if ($phone   === '' && !empty($current['phone_number'])) $phone = $current['phone_number'];
  if ($address === '' && !empty($current['address'])) $address = $current['address'];
  if ($studentId === null) $studentId = $current['student_id'];

  try {
    $stmt = $pdo->prepare("
      UPDATE users SET
        full_name      = :full_name,
        email          = :email,
        phone_number   = :phone,
        address        = :address,
        student_id     = :student_id
      WHERE user_id     = :user_id
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
    respond(500, ['success'=>false, 'message'=>'Update failed', 'error'=>$e->getMessage()]);
  }
}

// -------------- Unknown type --------------
respond(400, ['success'=>false, 'message'=>'Unknown type. Use type=show or type=update']);

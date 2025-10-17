    <?php
    ini_set('display_errors', 0);   // กัน warning/notice ไปปน JSON
error_reporting(E_ALL);

$origin = $_SERVER['HTTP_ORIGIN'] ?? '*';
header('Content-Type: application/json; charset=utf-8');
header('Vary: Origin');
header('Access-Control-Allow-Origin: ' . $origin); // ถ้าใช้ credentials ให้ระบุ origin ตรงๆ
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, Accept, X-Requested-With');
header('Access-Control-Max-Age: 86400');

// Preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
  http_response_code(204);
  exit;
}

    require_once __DIR__ . '/connect.php';

    function json_ok($data) {
  echo json_encode($data, JSON_UNESCAPED_UNICODE);
  exit;
}
function json_err($code, $msg, $extra = []) {
  http_response_code($code);
  echo json_encode(array_merge(['success' => false, 'message' => $msg], $extra), JSON_UNESCAPED_UNICODE);
  exit;
}

$type = $_GET['type'] ?? 'show';

try {
  switch ($type) {

    // ----------------------------------------------------
    // GET /courses.php?type=show&user_id=17
    // ----------------------------------------------------
    case 'show': {
      if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
        json_err(405, 'Method not allowed');
      }

      $userIdRaw = $_GET['user_id'] ?? '';
      if ($userIdRaw === '') {
        json_err(400, 'missing user_id');
      }
      $userId = (int)$userIdRaw;

      $sql = "
        SELECT
          c.course_id     AS id,
          c.course_name   AS name,
          c.code,
          c.credit,
          c.user_id,
          c.day_id,
          d.day_name      AS day_name,
          c.start_time,
          c.end_time,
          c.times,
          c.class         AS room,
          c.max_leave     AS sessions,
          c.teacher_name,
          c.section,
          c.created_at
        FROM course c
        LEFT JOIN day d ON d.day_id = c.day_id
        WHERE c.user_id = :uid
        ORDER BY c.created_at DESC, c.course_id DESC
      ";
      $st = $pdo->prepare($sql);
      $st->bindValue(':uid', $userId, PDO::PARAM_INT);
      $st->execute();
      $rows = $st->fetchAll();

      json_ok(['success' => true, 'data' => $rows]);
    }

    // ----------------------------------------------------
    // POST /courses.php?type=coursesadd
    // body JSON: { user_id, name, code, credit, teacher, day_id?, day?, start_time|start, end_time|end, room, sessions, section? }
    // ----------------------------------------------------
    case 'coursesadd': {
      if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        json_err(405, 'Method not allowed');
      }

      $input = json_decode(file_get_contents('php://input'), true);
      if (!$input || !is_array($input)) {
        json_err(400, 'Invalid JSON');
      }

      $userId   = isset($input['user_id']) ? (int)$input['user_id'] : 0;
      $name     = trim($input['name'] ?? '');
      $code     = trim($input['code'] ?? '');
      $credit   = (int)($input['credit'] ?? 0);
      $teacher  = trim($input['teacher'] ?? '');
      $dayId    = isset($input['day_id']) && $input['day_id'] !== '' ? (int)$input['day_id'] : 0;
      $dayName  = trim($input['day'] ?? '');
      $room     = trim($input['room'] ?? '');
      $sessions = (int)($input['sessions'] ?? 0);
      $section  = trim($input['section'] ?? '');

      // รองรับทั้ง start_time/end_time และ start/end
      $startStr = trim($input['start_time'] ?? $input['start'] ?? '09:00');
      $endStr   = trim($input['end_time']   ?? $input['end']   ?? '10:00');

      if ($userId <= 0 || $name === '' || $code === '') {
        json_err(400, 'missing required fields (user_id, name, code)', ['input' => $input]);
      }

      // map day ชื่อ → day_id ถ้ายังไม่ส่ง day_id มา
      if ($dayId === 0 && $dayName !== '') {
        $stDay = $pdo->prepare("SELECT day_id FROM day WHERE day_name = :name LIMIT 1");
        $stDay->execute([':name' => $dayName]);
        $found = $stDay->fetch();
        if ($found && isset($found['day_id'])) {
          $dayId = (int)$found['day_id'];
        }
      }

      // parse เวลา
      $startDT = DateTime::createFromFormat('H:i', $startStr);
      $endDT   = DateTime::createFromFormat('H:i', $endStr);
      if (!$startDT || !$endDT) {
        json_err(400, 'invalid time format, must be HH:mm');
      }
      if ($endDT < $startDT) {
        $endDT->modify('+1 day');
      }

      $diff  = $startDT->diff($endDT);
      $hours = $diff->h + ($diff->i / 60.0);     // 1.5 = 1 ชั่วโมงครึ่ง

      // ฟอร์แมตเวลาเป็น HH:MM:SS
      $startSQL = $startDT->format('H:i:s');
      $endSQL   = $endDT->format('H:i:s');

      try {
        $sql = "
          INSERT INTO course
            (code, credit, user_id, day_id, start_time, end_time, times, `class`, max_leave, teacher_name, `section`, course_name)
          VALUES
            (:code, :credit, :user_id, :day_id, :start_time, :end_time, :times, :class, :max_leave, :teacher_name, :section, :course_name)
        ";
        $st = $pdo->prepare($sql);
        $st->bindValue(':code',         $code,               PDO::PARAM_STR);
        $st->bindValue(':credit',       $credit,             PDO::PARAM_INT);
        $st->bindValue(':user_id',      $userId,             PDO::PARAM_INT);
        if ($dayId > 0) $st->bindValue(':day_id', $dayId, PDO::PARAM_INT);
        else            $st->bindValue(':day_id', null,   PDO::PARAM_NULL);
        $st->bindValue(':start_time',   $startSQL,           PDO::PARAM_STR);
        $st->bindValue(':end_time',     $endSQL,             PDO::PARAM_STR);
        $st->bindValue(':times',        $hours,              PDO::PARAM_STR); // แนะนำ DECIMAL(4,2)
        $st->bindValue(':class',        $room !== '' ? $room : null,          $room !== '' ? PDO::PARAM_STR : PDO::PARAM_NULL);
        $st->bindValue(':max_leave',    $sessions,           PDO::PARAM_INT);
        $st->bindValue(':teacher_name', $teacher !== '' ? $teacher : null,    $teacher !== '' ? PDO::PARAM_STR : PDO::PARAM_NULL);
        $st->bindValue(':section',      $section !== '' ? $section : null,    $section !== '' ? PDO::PARAM_STR : PDO::PARAM_NULL);
        $st->bindValue(':course_name',  $name,               PDO::PARAM_STR);
        $st->execute();

        $newId = (int)$pdo->lastInsertId();

        json_ok([
          'success' => true,
          'course'  => [
            'id'           => $newId,
            'name'         => $name,
            'code'         => $code,
            'user_id'      => $userId,
            'credit'       => $credit,
            'day_id'       => ($dayId ?: null),
            'start_time'   => $startSQL,
            'end_time'     => $endSQL,
            'times'        => $hours,
            'room'         => $room,
            'sessions'     => $sessions,
            'teacher_name' => $teacher,
            'section'      => $section,
          ],
        ]);
      } catch (Throwable $e) {
        json_err(500, 'insert error', ['error' => $e->getMessage()]);
      }
    }

    // ----------------------------------------------------
    // GET /courses.php?type=teacher_name&user_id=17
    // ----------------------------------------------------
    case 'teacher_name': {
      if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
        json_err(405, 'Method not allowed');
      }

      $userIdRaw = $_GET['user_id'] ?? '';
      if ($userIdRaw === '') {
        json_err(400, 'missing user_id');
      }
      $userId = (int)$userIdRaw;

      // ปรับ CONCAT ให้ตรงกับ schema ของตาราง users จริงของคุณ
      $sql = "SELECT TRIM(CONCAT(COALESCE(prefix,''), ' ', COALESCE(full_name,''))) AS name
              FROM users
              WHERE user_id = :uid AND role_id = 'teacher'
              LIMIT 1";
      $st = $pdo->prepare($sql);
      $st->bindValue(':uid', $userId, PDO::PARAM_INT);
      $st->execute();
      $row = $st->fetch();

      json_ok(['success' => true, 'name' => ($row['name'] ?? '')]);
    }

    // ----------------------------------------------------
    // GET /courses.php?type=days
    // ----------------------------------------------------
    case 'days': {
      if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
        json_err(405, 'Method not allowed');
      }
      $st = $pdo->query("SELECT day_id AS id, day_name AS name FROM day ORDER BY day_id ASC");
      $rows = $st->fetchAll();
      json_ok(['success' => true, 'data' => $rows]);
    }

    default:
      json_err(400, 'unknown type');
  }

} catch (Throwable $e) {
  json_err(500, 'server error', ['error' => $e->getMessage()]);
}
<?php
ini_set('display_errors', 0);   // กัน warning/notice ไปปน JSON
error_reporting(E_ALL);

include 'connect.php';
include 'config.php';

header('Content-Type: application/json; charset=utf-8');

function json_ok($data)
{
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit;
}

function json_err($code, $msg, $extra = [])
{
    http_response_code($code);
    echo json_encode(array_merge(['success' => false, 'message' => $msg], $extra), JSON_UNESCAPED_UNICODE);
    exit;
}

$type = $_GET['type'] ?? '';

try {

    if ($type === 'show_student') {
        if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
            json_err(405, 'Method not allowed');
        }

        $userIdRaw = $_GET['user_id'] ?? '';
        if ($userIdRaw === '') {
            json_err(400, 'missing user_id');
        }
        $userId = (int)$userIdRaw;

        $sql = "
            SELECT c.course_id AS id,
            c.course_name AS name,
            c.code,
            c.credit,
            c.user_id,
            c.day_id,
            c.start_time,
            c.end_time,
            c.times,
            c.class AS room,
            c.max_leave AS sessions,
            c.teacher_name,
            c.section,
            c.created_at
        FROM `schedule` s
        LEFT JOIN course c ON c.course_id = s.course_id
        LEFT JOIN schedule_detail d ON s.schedule_id = d.schedule_id
        WHERE d.user_id = :uid
            
        ";
        $st = $pdo->prepare($sql);
        $st->bindValue(':uid', $userId, PDO::PARAM_INT);
        $st->execute();
        $rows = $st->fetchAll();

        json_ok(['success' => true, 'data' => $rows]);
    }
    // ----------------------------------------------------
    // GET /courses.php?type=show&user_id=17
    // ----------------------------------------------------
    else if ($type === 'show') {
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
    // ----------------------------------------------------
    else if ($type === 'coursesadd') {
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

        $startStr = trim($input['start_time'] ?? $input['start'] ?? '09:00');
        $endStr   = trim($input['end_time']   ?? $input['end']   ?? '10:00');

        if ($userId <= 0 || $name === '' || $code === '') {
            json_err(400, 'missing required fields (user_id, name, code)', ['input' => $input]);
        }

        if ($dayId === 0 && $dayName !== '') {
            $stDay = $pdo->prepare("SELECT day_id FROM day WHERE day_name = :name LIMIT 1");
            $stDay->execute([':name' => $dayName]);
            $found = $stDay->fetch();
            if ($found && isset($found['day_id'])) {
                $dayId = (int)$found['day_id'];
            }
        }

        $startDT = DateTime::createFromFormat('H:i', $startStr);
        $endDT   = DateTime::createFromFormat('H:i', $endStr);
        if (!$startDT || !$endDT) {
            json_err(400, 'invalid time format, must be HH:mm');
        }
        if ($endDT < $startDT) {
            $endDT->modify('+1 day');
        }

        $diff  = $startDT->diff($endDT);
        $hours = $diff->h + ($diff->i / 60.0);

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
            $st->bindValue(':code',         $code, PDO::PARAM_STR);
            $st->bindValue(':credit',       $credit, PDO::PARAM_INT);
            $st->bindValue(':user_id',      $userId, PDO::PARAM_INT);
            $st->bindValue(':day_id',       $dayId > 0 ? $dayId : null, $dayId > 0 ? PDO::PARAM_INT : PDO::PARAM_NULL);
            $st->bindValue(':start_time',   $startSQL, PDO::PARAM_STR);
            $st->bindValue(':end_time',     $endSQL, PDO::PARAM_STR);
            $st->bindValue(':times',        $hours, PDO::PARAM_STR);
            $st->bindValue(':class',        $room !== '' ? $room : null, $room !== '' ? PDO::PARAM_STR : PDO::PARAM_NULL);
            $st->bindValue(':max_leave',    $sessions, PDO::PARAM_INT);
            $st->bindValue(':teacher_name', $teacher !== '' ? $teacher : null, $teacher !== '' ? PDO::PARAM_STR : PDO::PARAM_NULL);
            $st->bindValue(':section',      $section !== '' ? $section : null, $section !== '' ? PDO::PARAM_STR : PDO::PARAM_NULL);
            $st->bindValue(':course_name',  $name, PDO::PARAM_STR);
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
    // POST /courses_api.php?type=update_course
    // ----------------------------------------------------
    else if ($type === 'update_course') {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            json_err(405, 'Method not allowed');
        }

        $input = json_decode(file_get_contents('php://input'), true);
        if (!$input) {
            json_err(400, 'Invalid JSON');
        }

        $courseId = (int)($input['course_id'] ?? 0);
        if ($courseId <= 0) {
            json_err(400, 'missing course_id');
        }

        $day = trim($input['day'] ?? '');

        if ($day === '') {
            json_err(400, 'Missing day');
        }

        $sqlDay = "SELECT day_id FROM day WHERE day_name = :day_name LIMIT 1";
        $stmtDay = $pdo->prepare($sqlDay);
        $stmtDay->execute([
            ':day_name' => $day
        ]);

        $dayRow = $stmtDay->fetch();

        if (!$dayRow) {
            json_err(400, 'Invalid day name');
        }

        $day_id = (int)$dayRow['day_id'];

        $time = trim($input['time'] ?? '');
        if (!preg_match('/^\d{2}:\d{2}\s*-\s*\d{2}:\d{2}$/', $time)) {
            json_err(400, 'Invalid time format (HH:MM - HH:MM)');
        }

        [$start_time, $end_time] = array_map('trim', explode('-', $time));

        // SQL
        $sql = "
            UPDATE course SET
                course_name  = :name,
                code         = :code,
                credit       = :credit,
                teacher_name = :teacher,
                class        = :room,
                section      = :section,
                day_id       = :day_id,
                start_time   = :start_time,
                end_time     = :end_time,
                max_leave    = :sessions
            WHERE course_id = :id
        ";

        // Execute
        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            ':name'       => trim($input['name'] ?? ''),
            ':code'       => trim($input['code'] ?? ''),
            ':credit'     => (int)($input['credit'] ?? 0),
            ':teacher'    => trim($input['teacher'] ?? ''),
            ':room'       => trim($input['room'] ?? ''),
            ':section'    => trim($input['section'] ?? ''),
            ':day_id'     => $day_id,
            ':start_time' => $start_time,
            ':end_time'   => $end_time,
            ':sessions'   => (int)($input['sessions'] ?? 0),
            ':id'         => $courseId
        ]);

        json_ok(['success' => true]);
    }


    // ----------------------------------------------------
    // POST /courses_api.php?type=delete_course
    // ----------------------------------------------------
    else if ($type === 'delete_course') {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            json_err(405, 'Method not allowed');
        }

        $input = json_decode(file_get_contents('php://input'), true);
        if (!$input) {
            json_err(400, 'Invalid JSON');
        }

        $courseId = (int)($input['course_id'] ?? 0);
        if ($courseId <= 0) {
            json_err(400, 'missing course_id');
        }

        try {
            $pdo->beginTransaction();

            // 1) ลบ student ในคลาส
            $sql1 = "
                DELETE d
                FROM schedule_detail d
                INNER JOIN schedule s ON s.schedule_id = d.schedule_id
                WHERE s.course_id = :course_id
            ";
            $st1 = $pdo->prepare($sql1);
            $st1->execute([':course_id' => $courseId]);

            // 2) ลบ schedule
            $st2 = $pdo->prepare("DELETE FROM schedule WHERE course_id = :course_id");
            $st2->execute([':course_id' => $courseId]);

            // 3) ลบ course
            $st3 = $pdo->prepare("DELETE FROM course WHERE course_id = :course_id");
            $st3->execute([':course_id' => $courseId]);

            $pdo->commit();

            json_ok(['success' => true]);
        } catch (Throwable $e) {
            $pdo->rollBack();
            json_err(500, 'delete failed', ['error' => $e->getMessage()]);
        }
    }

    // ----------------------------------------------------
    // POST /courses_api.php?type=delete_student
    // ----------------------------------------------------
    else if ($type === 'delete_student') {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            json_err(405, 'Method not allowed');
        }

        $input = json_decode(file_get_contents('php://input'), true);
        if (!$input) {
            json_err(400, 'Invalid JSON');
        }

        $courseId = (int)($input['course_id'] ?? 0);
        $userId   = (int)($input['user_id'] ?? 0);

        if ($courseId <= 0 || $userId <= 0) {
            json_err(400, 'missing course_id or user_id');
        }

        // ลบ student ออกจาก schedule_detail โดยอิง course_id
        $sql = "
            DELETE d
            FROM schedule_detail d
            INNER JOIN schedule s ON s.schedule_id = d.schedule_id
            WHERE s.course_id = :course_id
            AND d.user_id   = :user_id
        ";

        $st = $pdo->prepare($sql);
        $st->execute([
            ':course_id' => $courseId,
            ':user_id'   => $userId,
        ]);

        json_ok(['success' => true]);
    }

    // ----------------------------------------------------
    // GET /courses.php?type=teacher_name&user_id=17
    // ----------------------------------------------------
    else if ($type === 'teacher_name') {
        if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
            json_err(405, 'Method not allowed');
        }

        $userIdRaw = $_GET['user_id'] ?? '';
        if ($userIdRaw === '') {
            json_err(400, 'missing user_id');
        }
        $userId = (int)$userIdRaw;

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
    else if ($type === 'days') {
        if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
            json_err(405, 'Method not allowed');
        }
        $st = $pdo->query("SELECT day_id AS id, day_name AS name FROM day ORDER BY day_id ASC");
        $rows = $st->fetchAll();
        json_ok(['success' => true, 'data' => $rows]);
    } // GET /courses_api.php?type=detail&course_id=123
    // GET /courses_api.php?type=detail&course_id=123
    // GET /courses_api.php?type=detail&course_id=123
    else if ($type === 'detail') {
        if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
            json_err(405, 'Method not allowed');
        }

        $course_id = filter_input(INPUT_GET, 'course_id', FILTER_VALIDATE_INT);
        if (!$course_id) {
            json_err(400, 'Invalid course_id');
        }

        // ดึงรายละเอียดรายวิชา + JOIN ตาราง day เพื่อได้ชื่อวัน
        $sql = "
        SELECT 
            c.course_id                              AS id,
            c.course_name                             AS name,
            c.code                                    AS code,
            c.credit                                  AS credit,
            c.teacher_name                            AS teacher,
            COALESCE(d.day_name, CAST(c.day_id AS CHAR)) AS day,  -- ถ้าไม่มีชื่อวัน จะส่ง day_id กลับเป็นข้อความ
            CASE
              WHEN c.start_time IS NOT NULL AND c.end_time IS NOT NULL
                THEN CONCAT(DATE_FORMAT(c.start_time, '%H:%i'), ' - ', DATE_FORMAT(c.end_time, '%H:%i'))
              WHEN c.start_time IS NOT NULL
                THEN DATE_FORMAT(c.start_time, '%H:%i')
              ELSE NULL
            END                                       AS time,
            c.class                                   AS room,
            c.section                                 AS section,
            c.max_leave                               AS sessions
        FROM course c
        LEFT JOIN `day` d ON d.day_id = c.day_id
        WHERE c.course_id = :id
        LIMIT 1
    ";

        $st = $pdo->prepare($sql);
        $st->execute([':id' => $course_id]);
        $course = $st->fetch(PDO::FETCH_ASSOC);

        if (!$course) {
            json_err(404, 'Course not found');
        }

        // ดึงรายชื่อนักศึกษาในคลาส (ปรับชื่อตารางให้ตรงของคุณ)
        // ตัวอย่างสมมติ: course_student(course_id, user_id), students(user_id, student_id, full_name)
        $sqlStu = "
    SELECT 
        d.user_id, 
        d.user_name AS name, 
        d.student_id
    FROM schedule_detail d
    INNER JOIN schedule s ON s.schedule_id = d.schedule_id
    WHERE s.course_id = :course_id
";
        $st2 = $pdo->prepare($sqlStu);
        $st2->execute([':course_id' => $course_id]); // ✅ ชื่อพารามิเตอร์ตรงกัน
        $students = $st2->fetchAll(PDO::FETCH_ASSOC);


        json_ok([
            'course'   => $course,
            'students' => $students,
        ]);
    } else {
        json_err(400, 'unknown type');
    }
} catch (Throwable $e) {
    json_err(500, 'server error', ['error' => $e->getMessage()]);
}
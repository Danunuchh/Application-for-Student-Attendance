<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

include 'connect.php';
include 'config.php';

$type   = $_GET['type'] ?? '';
$userId = $_GET['user_id'] ?? '';

if ($type === 'teacher') {

    $sql = "
        SELECT
            c.course_id,
            c.course_name,
            c.code,
            sd.student_id,
            sd.user_name,

            COUNT(ad.schedule_id) AS total_classes,

            SUM(
                CASE 
                    WHEN ad.leave_status = 0 
                     AND ad.time IS NOT NULL 
                    THEN 1 
                    ELSE 0 
                END
            ) AS attend_count,

            SUM(
                CASE 
                    WHEN ad.leave_status = 1 
                      OR ad.time IS NULL 
                    THEN 1 
                    ELSE 0 
                END
            ) AS absent_count

        FROM course c
        LEFT JOIN schedule s ON s.course_id = c.course_id
        LEFT JOIN schedule_detail sd ON sd.schedule_id = s.schedule_id
        LEFT JOIN attendance_detail ad
               ON ad.schedule_id = s.schedule_id
              AND ad.student_id = sd.student_id
        WHERE c.user_id = ?
        GROUP BY
            c.course_id,
            c.course_name,
            sd.student_id,
            sd.user_name
        ORDER BY c.course_id
    ";

    $stmt = $pdo->prepare($sql);
    $stmt->execute([$userId]);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // ---------- แปลงเป็น Header / Detail ----------
    $result = [];

    foreach ($rows as $row) {
        $cid = $row['course_id'];

        // สร้าง header ถ้ายังไม่มี
        if (!isset($result[$cid])) {
            $result[$cid] = [
                'course_id'   => $cid,
                'course_name' => $row['course_name'],
                'code' => $row['code'],
                'students'    => []
            ];
        }

        $total  = (int)$row['total_classes'];
        $attend = (int)$row['attend_count'];
        $absent = (int)$row['absent_count'];

        $attendPercent = $total > 0 ? round(($attend / $total) * 100, 2) : 0;
        $absentPercent = $total > 0 ? round(($absent / $total) * 100, 2) : 0;

        // ใส่ detail (student)
        $result[$cid]['students'][] = [
            'student_id'    => $row['student_id'],
            'student_name'  => $row['user_name'],
            'total_classes'   => $total,
            'attend'          => $attend,
            'absent'          => $absent,
            'attend_percent'  => $attendPercent,
            'absent_percent'  => $absentPercent,
        ];
    }

    echo json_encode([
        'success' => true,
        'data'    => array_values($result)
    ]);
} else if ($type == 'student') {
    $sql = "
        SELECT
            u.full_name,
            u.student_id,
            s.course_id,
            c.code,
            s.course_name,

            COUNT(ad.schedule_id) AS total_classes,

            SUM(
                CASE
                    WHEN ad.leave_status = 0
                    AND ad.time IS NOT NULL
                    THEN 1
                    ELSE 0
                END
            ) AS attend_count,

            SUM(
                CASE
                    WHEN ad.leave_status = 1
                    OR ad.time IS NULL
                    THEN 1
                    ELSE 0
                END
            ) AS absent_count

        FROM users u

        JOIN schedule_detail sd
            ON sd.student_id = u.student_id

        JOIN schedule s
            ON s.schedule_id = sd.schedule_id

        LEFT JOIN attendance_detail ad
            ON ad.student_id = u.student_id
        AND ad.schedule_id = s.schedule_id

        LEFT JOIN course c ON c.course_id = s.course_id

        WHERE u.user_id = ?

        GROUP BY
            u.student_id,
            u.full_name,
            s.course_id,
            s.course_name;
    ";

    $stmt = $pdo->prepare($sql);
    $stmt->execute([$userId]);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // ---------- แปลงเป็น Header / Detail ----------
    $result = [];

    foreach ($rows as $row) {
        $cid = $row['course_id'];

        if (!isset($result[$cid])) {
            $result[$cid] = [
                'course_id'   => $cid,
                'course_name' => $row['course_name'],
                'code'        => $row['code'],
                'students'    => []
            ];
        }

        $total  = (int)$row['total_classes'];
        $attend = (int)$row['attend_count'];
        $absent = (int)$row['absent_count'];

        $attendPercent = $total > 0 ? round(($attend / $total) * 100, 2) : 0;
        $absentPercent = $total > 0 ? round(($absent / $total) * 100, 2) : 0;

        $result[$cid]['students'][] = [
            'student_id'      => $row['student_id'],
            'student_name'    => $row['full_name'], // ✅ แก้แล้ว
            'total_classes'   => $total,
            'attend'          => $attend,
            'absent'          => $absent,
            'attend_percent'  => $attendPercent,
            'absent_percent'  => $absentPercent,
        ];
    }

    echo json_encode([
        'success' => true,
        'data'    => array_values($result)
    ]);
}

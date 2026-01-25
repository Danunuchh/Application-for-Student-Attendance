<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

include 'connect.php';
include 'config.php';

$type   = $_GET['type'] ?? '';

if ($type === 'student_list') {

    $sql = "
        SELECT 
            u.student_id,
            u.full_name
        FROM users u
        WHERE u.role_id = 'student'
        ORDER BY u.student_id
    ";

    $stmt = $pdo->prepare($sql);
    $stmt->execute();

    echo json_encode([
        'success' => true,
        'data' => $stmt->fetchAll(PDO::FETCH_ASSOC)
    ]);
    exit;
} if ($type === 'teacher_list') {

    $sql = "
        SELECT 
            u.student_id,
            u.full_name
        FROM users u
        WHERE u.role_id = 'teacher'
    ";

    $stmt = $pdo->prepare($sql);
    $stmt->execute();

    echo json_encode([
        'success' => true,
        'data' => $stmt->fetchAll(PDO::FETCH_ASSOC)
    ]);
    exit;
}
else if ($type === 'student_detail') {

    $studentId = $_GET['student_id'] ?? null;

    if (!$studentId) {
        echo json_encode([
            'success' => false,
            'message' => 'student_id is required'
        ]);
        exit;
    }
                    // ad.leave_status = 1 AND 

    $sql = "
        SELECT 
            u.student_id,
            u.full_name,
            s.course_name,
            c.code,
            COUNT(ad.schedule_id) AS total_classes,
            SUM(
                CASE 
                    WHEN ad.leave_status = 0 
                     AND ad.time IS NOT NULL 
                    THEN 1 ELSE 0 
                END
            ) AS attend_count,
            SUM(
                CASE 
                    WHEN 
                      ad.time IS NULL 
                    THEN 1 ELSE 0 
                END
            ) AS absent_count
        FROM users u
        LEFT JOIN schedule_detail sd 
            ON sd.student_id = u.student_id
        LEFT JOIN schedule s 
            ON s.schedule_id = sd.schedule_id 
        LEFT JOIN course c 
            ON s.course_id = c.course_id
        LEFT JOIN attendance_detail ad
            ON ad.schedule_id = s.schedule_id
            AND ad.student_id = sd.student_id
        WHERE u.student_id = :student_id
        GROUP BY
            c.course_id,
            c.code,
            s.course_name,
            u.student_id,
            u.full_name
    ";

    $stmt = $pdo->prepare($sql);
    $stmt->execute([
        ':student_id' => $studentId
    ]);

    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (!$rows) {
        echo json_encode([
            'success' => true,
            'data' => null
        ]);
        exit;
    }

    $result = [
        'student_id' => $rows[0]['student_id'],
        'full_name'  => $rows[0]['full_name'],
        'courses'    => []
    ];

    foreach ($rows as $row) {
        $result['courses'][] = [
            'course_code'   => $row['code'],
            'course_name'   => $row['course_name'],
            'total_classes' => (int)$row['total_classes'],
            'attend_count'  => (int)$row['attend_count'],
            'absent_count'  => (int)$row['absent_count'],
        ];
    }

    echo json_encode([
        'success' => true,
        'data' => $result
    ]);
    exit;
} else if ($type == 'teacher') {
    $sql = "
       SELECT 
            u.student_id,
            u.full_name
        FROM users u
        WHERE u.role _id = 'teacher'
    ";

    $stmt = $pdo->prepare($sql);
    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'success' => true,
        'data' => $rows
    ]);
} else if ($type == 'dashbord') {
}

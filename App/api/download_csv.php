<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

include 'connect.php';
include 'config.php';

/* ===============================
   รับค่า
================================ */
$course_id   = $_GET['course_id'] ?? 0;
$course_name = $_GET['course_name'] ?? 'รายวิชา';

if (!$course_id) {
    die('course_id is required');
}

/* ===============================
   Header สำหรับ CSV
================================ */
$filename = "รายงานผลการเข้าเรียน_{$course_name}.csv";

header('Content-Type: text/csv; charset=UTF-8');
header("Content-Disposition: attachment; filename=\"$filename\"");
header('Pragma: no-cache');
header('Expires: 0');

/* ใส่ BOM ให้ Excel อ่านภาษาไทยถูก */
echo "\xEF\xBB\xBF";

/* ===============================
   1) ดึงวันเรียน
================================ */
$sqlDays = "
    SELECT day
    FROM attendance
    WHERE course_id = ?
    ORDER BY day
";
$stmt = $pdo->prepare($sqlDays);
$stmt->execute([$course_id]);
$allDays = $stmt->fetchAll(PDO::FETCH_COLUMN);

/* ===============================
   2) ดึงข้อมูลเช็คชื่อ
================================ */
$sql = "
    SELECT
        ad.student_id,
        ad.student_name,
        a.day,
        ad.time,
        ad.leave_status,
        c.code
    FROM attendance a
    LEFT JOIN attendance_detail ad
           ON ad.attendance_id = a.attendance_id
    LEFT JOIN course c
           ON c.course_id = a.course_id
    WHERE a.course_id = ?
    ORDER BY ad.student_id, a.day
";
$stmt = $pdo->prepare($sql);
$stmt->execute([$course_id]);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

/* ===============================
   3) จัดข้อมูล
================================ */
$data = [];

foreach ($rows as $r) {
    if (!$r['student_id']) continue;

    $sid = $r['student_id'];
    $day = $r['day'];

    if (!isset($data[$sid])) {
        $data[$sid] = [
            'student_id'   => $sid,
            'student_name' => $r['student_name'],
            'days'         => [],
            'attend'       => 0,
            'absent'       => 0
        ];
    }

    $code = $r['code'];

    $status = (
        $r['leave_status'] == 0 &&
        $r['time'] !== null
    ) ? 1 : 0;

    $data[$sid]['days'][$day] = $status;

    if ($status) {
        $data[$sid]['attend']++;
    } else {
        $data[$sid]['absent']++;
    }
}

/* เติมวันให้ครบ */
foreach ($data as &$stu) {
    foreach ($allDays as $d) {
        if (!isset($stu['days'][$d])) {
            $stu['days'][$d] = 0;
            $stu['absent']++;
        }
    }
    ksort($stu['days']);
}
unset($stu);

/* ===============================
   4) เขียน CSV
================================ */
$output = fopen('php://output', 'w');

fputcsv($output, [$code, $course_name]);

/* เว้นบรรทัด */
fputcsv($output, []);

/* Header row */
$header = ['รหัสนักศึกษา', 'ชื่อ-สกุล'];
foreach ($allDays as $d) {
    $header[] = date('d/m', timestamp: strtotime($d));
}
$header[] = 'จำนวนคาบทั้งหมด';
$header[] = 'รวมมา';
$header[] = 'รวมขาด';


fputcsv($output, $header);

/* จำนวนคาบทั้งหมด */
$totalClasses = count($allDays);

/* Data rows */
foreach ($data as $stu) {
    $row = [
        $stu['student_id'],
        $stu['student_name']
    ];

    foreach ($allDays as $d) {
        $row[] = $stu['days'][$d]; // 1 = มา, 0 = ขาด
    }

    $row[] = $totalClasses;
    $row[] = $stu['attend'];
    $row[] = $stu['absent'];

    fputcsv($output, $row);
}

fclose($output);
exit;

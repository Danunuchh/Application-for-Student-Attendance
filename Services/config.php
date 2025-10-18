<?php
$origin = $_SERVER['HTTP_ORIGIN'] ?? '*';
header('Content-Type: application/json; charset=utf-8');
header('Vary: Origin');
header('Access-Control-Allow-Origin: ' . $origin); // ถ้าใช้ credentials ให้ระบุ origin ตรงๆ
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, Accept, X-Requested-With');
header('Access-Control-Max-Age: 86400');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
      header('Access-Control-Allow-Origin: *');
      header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
      header('Access-Control-Allow-Headers: Content-Type, Authorization, Accept, X-Requested-With');
      http_response_code(204);
      exit;
}
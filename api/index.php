<?php
header('Access-Control-Allow-Origin: ' . getenv('FRONTEND_URL') ?: 'http://localhost:3000');
header('Access-Control-Allow-Credentials: true');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/middleware/auth.php';

$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$path = str_replace('/api', '', $path);
$path = trim($path, '/');

// ─── Route Parser ───────────────────────────────────────────────────────────
$routes = [
    // Auth
    'POST /auth/register'       => 'v1/auth/register.php',
    'POST /auth/login'          => 'v1/auth/login.php',
    'POST /auth/logout'         => 'v1/auth/logout.php',
    'POST /auth/refresh'        => 'v1/auth/refresh.php',
    'GET /auth/me'              => 'v1/auth/me.php',

    // Schools
    'GET /schools'              => 'v1/schools/list.php',
    'GET /schools/:id'          => 'v1/schools/get.php',
    'POST /schools'             => 'v1/schools/create.php',
    'PUT /schools/:id'          => 'v1/schools/update.php',
    'DELETE /schools/:id'       => 'v1/schools/delete.php',

    // Users
    'GET /users'                => 'v1/users/list.php',
    'GET /users/:id'            => 'v1/users/get.php',
    'POST /users'               => 'v1/users/create.php',
    'PUT /users/:id'            => 'v1/users/update.php',
    'DELETE /users/:id'         => 'v1/users/delete.php',

    // Dashboard (role-based)
    'GET /dashboard'            => 'v1/dashboard/index.php',

    // Classes
    'GET /classes'              => 'v1/classes/list.php',
    'POST /classes'             => 'v1/classes/create.php',
    'PUT /classes/:id'          => 'v1/classes/update.php',
    'DELETE /classes/:id'       => 'v1/classes/delete.php',

    // Students
    'GET /students'             => 'v1/students/list.php',
    'GET /students/:id'         => 'v1/students/get.php',
    'POST /students'            => 'v1/students/create.php',
    'PUT /students/:id'         => 'v1/students/update.php',

    // Attendance
    'GET /attendance'           => 'v1/attendance/list.php',
    'POST /attendance'          => 'v1/attendance/create.php',
    'PUT /attendance/:id'       => 'v1/attendance/update.php',

    // Grades
    'GET /grades'               => 'v1/grades/list.php',
    'POST /grades'              => 'v1/grades/create.php',
    'PUT /grades/:id'           => 'v1/grades/update.php',

    // Assignments
    'GET /assignments'          => 'v1/assignments/list.php',
    'POST /assignments'         => 'v1/assignments/create.php',
    'PUT /assignments/:id'      => 'v1/assignments/update.php',
    'POST /assignments/:id/submit' => 'v1/assignments/submit.php',

    // Fees
    'GET /fees'                 => 'v1/fees/list.php',
    'POST /fees'                => 'v1/fees/create.php',
    'PUT /fees/:id'             => 'v1/fees/update.php',

    // Announcements
    'GET /announcements'        => 'v1/announcements/list.php',
    'POST /announcements'       => 'v1/announcements/create.php',
    'PUT /announcements/:id'    => 'v1/announcements/update.php',
];

// ─── Match Route ────────────────────────────────────────────────────────────
$route_file = null;
$route_params = [];

foreach ($routes as $route => $file) {
    [$route_method, $route_path] = explode(' ', $route, 2);

    if ($method !== $route_method) continue;

    $pattern = preg_replace_callback('/:([a-z_]+)/', function($m) {
        return '(?P<' . $m[1] . '>[0-9a-zA-Z-]+)';
    }, $route_path);

    if (preg_match('#^' . $pattern . '$#', $path, $matches)) {
        $route_file = $file;
        foreach ($matches as $k => $v) {
            if (!is_numeric($k)) $route_params[$k] = $v;
        }
        break;
    }
}

if (!$route_file) {
    http_response_code(404);
    die(json_encode(['error' => 'Endpoint not found']));
}

// ─── Include Route Handler ──────────────────────────────────────────────────
$_GET = array_merge($_GET, $route_params);
require_once __DIR__ . '/' . $route_file;

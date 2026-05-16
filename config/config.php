<?php
// ─── AI Smart School Management System - API Config ──────────────────────────

define('APP_NAME', 'AI Smart School API');
define('APP_VERSION', '1.0.0');
define('API_URL', getenv('API_URL') ?: 'http://localhost:8000');
define('FRONTEND_URL', getenv('FRONTEND_URL') ?: 'http://localhost:3000');

// ─── JWT Configuration ──────────────────────────────────────────────────────
define('JWT_SECRET', getenv('JWT_SECRET') ?: 'your-secret-key-change-in-production');
define('JWT_EXPIRY', 7200); // 2 hours

// ─── Database ───────────────────────────────────────────────────────────────
define('DB_HOST', getenv('DB_HOST') ?: 'localhost');
define('DB_PORT', getenv('DB_PORT') ?: '5432');
define('DB_NAME', getenv('DB_NAME') ?: 'ai_school');
define('DB_USER', getenv('DB_USER') ?: 'postgres');
define('DB_PASS', getenv('DB_PASS') ?: '');

// ─── Environment ────────────────────────────────────────────────────────────
define('APP_ENV', getenv('APP_ENV') ?: 'production');

if (APP_ENV === 'development') {
    error_reporting(E_ALL);
    ini_set('display_errors', '1');
} else {
    error_reporting(0);
    ini_set('display_errors', '0');
}

// ─── Roles ──────────────────────────────────────────────────────────────────
define('ROLES', [
    'super_admin'  => 'Super Admin',
    'admin'        => 'Admin',
    'school_owner' => 'School Owner',
    'teacher'      => 'Teacher',
    'student'      => 'Student',
    'parent'       => 'Parent',
    'staff'        => 'Staff',
    'government'   => 'Government',
    'community'    => 'Community',
]);

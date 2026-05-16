<?php
requireRole(['super_admin', 'admin']);

$page     = max(1, (int)($_GET['page'] ?? 1));
$per_page = 20;
$search   = trim($_GET['q'] ?? '');
$role     = trim($_GET['role'] ?? '');
$offset   = ($page - 1) * $per_page;

$where  = "WHERE status='active'";
$params = [];

if ($search) {
    $where   .= " AND (CONCAT(first_name,' ',last_name) LIKE ? OR email LIKE ?)";
    $params[] = "%{$search}%";
    $params[] = "%{$search}%";
}

if ($role) {
    $where   .= " AND role = ?";
    $params[] = $role;
}

$users = Database::fetchAll(
    "SELECT id, first_name, last_name, email, role, school_id, status, created_at
     FROM users {$where} ORDER BY created_at DESC LIMIT ? OFFSET ?",
    array_merge($params, [$per_page, $offset])
);

$total = Database::fetchOne("SELECT COUNT(*) AS count FROM users {$where}", $params)['count'] ?? 0;

sendJson([
    'data'       => $users,
    'pagination' => ['total' => $total, 'page' => $page, 'per_page' => $per_page],
]);

<?php
requireRole(['super_admin', 'admin']);

$page = (int)($_GET['page'] ?? 1);
$per_page = 20;
$search = $_GET['q'] ?? '';
$role = $_GET['role'] ?? '';

$where = "WHERE status='active'";
$params = [];
$param_idx = 1;

if ($search) {
    $where .= " AND (first_name||' '||last_name ILIKE \${$param_idx} OR email ILIKE \${$param_idx})";
    $params[] = "%{$search}%";
    $param_idx++;
}

if ($role) {
    $where .= " AND role = \${$param_idx}";
    $params[] = $role;
    $param_idx++;
}

$offset = ($page - 1) * $per_page;
$users = Database::fetchAll(
    "SELECT id, first_name, last_name, email, role, school_id, status, created_at FROM users {$where}
     ORDER BY created_at DESC LIMIT \${$param_idx} OFFSET \$" . ($param_idx + 1),
    array_merge($params, [$per_page, $offset])
);

$total = Database::fetchOne("SELECT COUNT(*) as count FROM users {$where}", $params)['count'] ?? 0;

sendJson([
    'data' => $users,
    'pagination' => [
        'total'    => $total,
        'page'     => $page,
        'per_page' => $per_page,
    ],
]);

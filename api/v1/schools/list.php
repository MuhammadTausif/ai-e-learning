<?php
requireRole(['super_admin', 'admin']);

$page     = max(1, (int)($_GET['page'] ?? 1));
$per_page = 20;
$search   = trim($_GET['q'] ?? '');
$offset   = ($page - 1) * $per_page;

$where  = "WHERE status='active'";
$params = [];

if ($search) {
    $where   .= " AND name LIKE ?";
    $params[] = "%{$search}%";
}

$schools = Database::fetchAll(
    "SELECT * FROM schools {$where} ORDER BY created_at DESC LIMIT ? OFFSET ?",
    array_merge($params, [$per_page, $offset])
);

$total = Database::fetchOne("SELECT COUNT(*) AS count FROM schools {$where}", $params)['count'] ?? 0;

sendJson([
    'data'       => $schools,
    'pagination' => ['total' => $total, 'page' => $page, 'per_page' => $per_page],
]);

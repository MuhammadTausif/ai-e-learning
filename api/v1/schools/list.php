<?php
requireRole(['super_admin', 'admin']);

$page = (int)($_GET['page'] ?? 1);
$per_page = 20;
$search = $_GET['q'] ?? '';

$where = "WHERE status='active'";
$params = [];
if ($search) {
    $where .= " AND name ILIKE $1";
    $params = ["%{$search}%"];
}

$offset = ($page - 1) * $per_page;
$schools = Database::fetchAll(
    "SELECT * FROM schools {$where} ORDER BY created_at DESC LIMIT $" . (count($params) + 1) . " OFFSET $" . (count($params) + 2),
    array_merge($params, [$per_page, $offset])
);

$total = Database::fetchOne("SELECT COUNT(*) as count FROM schools {$where}", $params)['count'] ?? 0;

sendJson([
    'data'  => $schools,
    'pagination' => [
        'total'    => $total,
        'page'     => $page,
        'per_page' => $per_page,
    ],
]);

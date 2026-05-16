<?php
requireRole(['super_admin', 'admin']);
$id = (int)($_GET['id'] ?? 0);
$body = getRequestBody();

Database::query(
    'UPDATE schools SET name=$1, address=$2, city=$3, state=$4, country=$5, phone=$6, email=$7, website=$8, status=$9 WHERE id=$10',
    [
        $body['name'] ?? '',
        $body['address'] ?? '',
        $body['city'] ?? '',
        $body['state'] ?? '',
        $body['country'] ?? 'Pakistan',
        $body['phone'] ?? '',
        $body['email'] ?? '',
        $body['website'] ?? '',
        $body['status'] ?? 'active',
        $id,
    ]
);

sendJson(['message' => 'School updated']);

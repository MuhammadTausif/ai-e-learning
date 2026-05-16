<?php
requireRole(['super_admin', 'admin']);
$id   = (int)($_GET['id'] ?? 0);
$body = getRequestBody();

Database::query(
    'UPDATE schools SET name=?, address=?, city=?, state=?, country=?, phone=?, email=?, website=?, status=? WHERE id=?',
    [
        $body['name']    ?? '',
        $body['address'] ?? '',
        $body['city']    ?? '',
        $body['state']   ?? '',
        $body['country'] ?? 'Pakistan',
        $body['phone']   ?? '',
        $body['email']   ?? '',
        $body['website'] ?? '',
        $body['status']  ?? 'active',
        $id,
    ]
);

sendJson(['message' => 'School updated']);

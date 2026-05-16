<?php
requireRole(['super_admin', 'admin']);
$body = getRequestBody();

$name = trim($body['name'] ?? '');
if (!$name) sendError('School name is required', 400);

Database::query(
    'INSERT INTO schools (name, address, city, state, country, phone, email, website, status, created_at)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, NOW())',
    [
        $name,
        $body['address'] ?? '',
        $body['city'] ?? '',
        $body['state'] ?? '',
        $body['country'] ?? 'Pakistan',
        $body['phone'] ?? '',
        $body['email'] ?? '',
        $body['website'] ?? '',
        'active',
    ]
);

$school_id = (int)Database::lastId();
$school = Database::fetchOne('SELECT * FROM schools WHERE id = $1', [$school_id]);

sendJson(['data' => $school], 201);

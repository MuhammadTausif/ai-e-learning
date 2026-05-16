<?php
$body = getRequestBody();

$email = $body['email'] ?? '';
$password = $body['password'] ?? '';

if (!$email || !$password) {
    sendError('Email and password required', 400);
}

$user = Database::fetchOne(
    'SELECT * FROM users WHERE email = $1 AND status = $2',
    [$email, 'active']
);

if (!$user || !password_verify($password, $user['password'])) {
    sendError('Invalid credentials', 401);
}

// Update last login
Database::query('UPDATE users SET last_login = NOW() WHERE id = $1', [$user['id']]);

// Generate JWT
$token = JWT::encode([
    'id'        => $user['id'],
    'email'     => $user['email'],
    'role'      => $user['role'],
    'school_id' => $user['school_id'],
]);

sendJson([
    'token' => $token,
    'user'  => [
        'id'        => $user['id'],
        'name'      => $user['first_name'] . ' ' . $user['last_name'],
        'email'     => $user['email'],
        'role'      => $user['role'],
        'school_id' => $user['school_id'],
        'avatar'    => $user['avatar'],
    ],
], 200);

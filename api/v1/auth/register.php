<?php
$body = getRequestBody();

$first_name = trim($body['first_name'] ?? '');
$last_name  = trim($body['last_name'] ?? '');
$email      = trim($body['email'] ?? '');
$password   = $body['password'] ?? '';
$role       = $body['role'] ?? 'community';

if (!$first_name || !$last_name || !$email || !$password) {
    sendError('Missing required fields', 400);
}

if (strlen($password) < 8) {
    sendError('Password must be at least 8 characters', 400);
}

if (!array_key_exists($role, ROLES)) {
    sendError('Invalid role', 400);
}

// Check if email exists
$existing = Database::fetchOne(
    'SELECT id FROM users WHERE email = $1',
    [$email]
);
if ($existing) {
    sendError('Email already registered', 409);
}

// Create user
$hash = password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]);
Database::query(
    'INSERT INTO users (first_name, last_name, email, password, role, status, created_at)
     VALUES ($1, $2, $3, $4, $5, $6, NOW())',
    [$first_name, $last_name, $email, $hash, $role, 'active']
);

$user_id = (int)Database::lastId();

// If student, create student profile
if ($role === 'student') {
    Database::query(
        'INSERT INTO student_profiles (user_id, created_at) VALUES ($1, NOW())',
        [$user_id]
    );
}

sendJson(['message' => 'User registered successfully'], 201);

<?php
$user_data = requireAuth();
$user      = Database::fetchOne(
    'SELECT id, first_name, last_name, email, role, school_id, avatar FROM users WHERE id = ?',
    [$user_data['id']]
);

if (!$user) {
    sendError('User not found', 404);
}

sendJson([
    'user' => [
        'id'        => $user['id'],
        'name'      => $user['first_name'] . ' ' . $user['last_name'],
        'email'     => $user['email'],
        'role'      => $user['role'],
        'school_id' => $user['school_id'],
        'avatar'    => $user['avatar'],
    ],
]);

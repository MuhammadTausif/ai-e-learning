<?php
$user_data = requireAuth();

// Generate new token
$token = JWT::encode([
    'id'        => $user_data['id'],
    'email'     => $user_data['email'],
    'role'      => $user_data['role'],
    'school_id' => $user_data['school_id'],
]);

sendJson(['token' => $token], 200);

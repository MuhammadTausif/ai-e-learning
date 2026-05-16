<?php
require_once __DIR__ . '/../../config/config.php';
require_once __DIR__ . '/../../config/jwt.php';

function getAuthToken(): ?string {
    $headers = getallheaders();
    $auth = $headers['Authorization'] ?? '';

    if (preg_match('/Bearer\s+(.+)/i', $auth, $matches)) {
        return $matches[1];
    }
    return null;
}

function requireAuth(): array {
    $token = getAuthToken();
    if (!$token) {
        http_response_code(401);
        die(json_encode(['error' => 'Unauthorized: missing token']));
    }

    $decoded = JWT::decode($token);
    if (!$decoded) {
        http_response_code(401);
        die(json_encode(['error' => 'Unauthorized: invalid token']));
    }

    return $decoded;
}

function requireRole(string|array $roles): array {
    $user = requireAuth();
    $allowed = is_array($roles) ? $roles : [$roles];

    if ($user['role'] === 'super_admin') return $user;
    if (!in_array($user['role'], $allowed, true)) {
        http_response_code(403);
        die(json_encode(['error' => 'Forbidden: insufficient permissions']));
    }

    return $user;
}

function getRequestBody(): array {
    $input = file_get_contents('php://input');
    return json_decode($input, true) ?? [];
}

function sendJson(array $data, int $code = 200): never {
    http_response_code($code);
    header('Content-Type: application/json');
    header('Access-Control-Allow-Origin: ' . FRONTEND_URL);
    header('Access-Control-Allow-Credentials: true');
    echo json_encode($data);
    exit;
}

function sendError(string $message, int $code = 400): never {
    sendJson(['error' => $message], $code);
}

<?php
require_once __DIR__ . '/config.php';

class JWT {
    public static function encode(array $payload): string {
        $header = ['typ' => 'JWT', 'alg' => 'HS256'];
        $payload['iat'] = time();
        $payload['exp'] = time() + JWT_EXPIRY;

        $header_enc = self::urlSafeBase64Encode(json_encode($header));
        $payload_enc = self::urlSafeBase64Encode(json_encode($payload));
        $signature = self::sign($header_enc . '.' . $payload_enc);

        return $header_enc . '.' . $payload_enc . '.' . $signature;
    }

    public static function decode(string $token): ?array {
        $parts = explode('.', $token);
        if (count($parts) !== 3) return null;

        [$header_enc, $payload_enc, $signature] = $parts;

        $expected_sig = self::sign($header_enc . '.' . $payload_enc);
        if (!hash_equals($signature, $expected_sig)) return null;

        $payload = json_decode(self::urlSafeBase64Decode($payload_enc), true);
        if (!is_array($payload)) return null;

        if (isset($payload['exp']) && $payload['exp'] < time()) return null;

        return $payload;
    }

    private static function sign(string $msg): string {
        return self::urlSafeBase64Encode(
            hash_hmac('sha256', $msg, JWT_SECRET, true)
        );
    }

    private static function urlSafeBase64Encode(string $data): string {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }

    private static function urlSafeBase64Decode(string $data): string {
        return base64_decode(strtr($data, '-_', '+/'));
    }
}

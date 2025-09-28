<?php

namespace App\Services;

use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use Illuminate\Http\Request;

class HLSTokenService
{
    /**
     * Generate JWT token for HLS video access
     *
     * @param int $userId User ID
     * @param string $videoId Video UUID/ID
     * @param Request $request Current request for IP and User-Agent
     * @param int $expirationMinutes Token expiration in minutes (default: 60)
     * @return string JWT token
     */
    public function generateToken(int $userId, string $videoId, Request $request, int $expirationMinutes = 60): string
    {
        $payload = [
            'sub' => $userId,                              // Subject (user ID)
            'video_id' => $videoId,                        // Video identifier
            'iat' => time(),                              // Issued at
            'exp' => time() + ($expirationMinutes * 60),  // Expires
            'jti' => uniqid('hls_', true),                // Unique token ID
            'ip' => $request->ip(),                       // Bind to client IP
            'userAgent' => $request->userAgent(),         // User agent
        ];

        // Sign with your secret key (store this in .env as VIDEO_JWT_SECRET)
        return JWT::encode($payload, config('video.video_jwt_secret'), 'HS256');
    }

    /**
     * Validate JWT token (useful for API validation)
     *
     * @param string $token JWT token
     * @return array|null Decoded payload or null if invalid
     */
    public function validateToken(string $token): ?array
    {
        try {
            $decoded = JWT::decode($token, new Key(config('video.video_jwt_secret'), 'HS256'));
            return (array) $decoded;
        } catch (\Exception $e) {
            return null;
        }
    }

    /**
     * Generate HLS playlist URL with token
     *
     * @param string $baseUrl Base URL of your CDN/nginx server
     * @param string $videoId Video UUID/ID
     * @param string $token JWT token
     * @return string Complete URL with token
     */
    public function generatePlaylistUrl(string $baseUrl, string $videoId, string $token): string
    {
        return rtrim($baseUrl, '/') . '/' . $videoId . '/index.m3u8?token=' . $token;
    }

    /**
     * Check if user has access to specific video
     * You can customize this method based on your business logic
     *
     * @param int $userId User ID
     * @param string $videoId Video UUID/ID
     * @return bool
     */
    public function userHasAccessToVideo(int $userId, string $videoId): bool
    {
        // Add your business logic here
        // For example:
        // - Check if user owns the video
        // - Check if video is public
        // - Check if user has subscription
        // - Check if user purchased the video
        
        // Placeholder implementation
        return true;
    }

    /**
     * Generate token with access validation
     *
     * @param int $userId User ID
     * @param string $videoId Video UUID/ID
     * @param Request $request Current request
     * @param int $expirationMinutes Token expiration in minutes
     * @return string|null JWT token or null if access denied
     */
    public function generateTokenWithValidation(int $userId, string $videoId, Request $request, int $expirationMinutes = 60): ?string
    {
        if (!$this->userHasAccessToVideo($userId, $videoId)) {
            return null;
        }

        return $this->generateToken($userId, $videoId, $request, $expirationMinutes);
    }
}
-- token_auth.lua
-- HLS JWT Token Authentication for nginx with Laravel integration

local jwt = require "resty.jwt"
local cjson = require "cjson"

local _M = {}

-- Configuration - JWT secret should match your Laravel app's video_jwt_secret
local JWT_SECRET = os.getenv("VIDEO_JWT_SECRET") or "your-laravel-jwt-secret"

-- Function to validate JWT token
function _M.validate_token()
    local args = ngx.req.get_uri_args()
    local token = args["token"]
    local path = ngx.var.uri
    local client_ip = ngx.var.remote_addr
    local user_agent = ngx.var.http_user_agent or ""
    
    if not token then
        ngx.log(ngx.ERR, "No token provided")
        ngx.status = 403
        ngx.say("Access denied: No token provided")
        ngx.exit(403)
    end
    
    -- Verify and decode JWT token
    local jwt_obj = jwt:verify(JWT_SECRET, token)
    
    if not jwt_obj.valid then
        ngx.log(ngx.ERR, "Invalid JWT token: " .. (jwt_obj.reason or "unknown"))
        ngx.status = 403
        ngx.say("Access denied: Invalid token")
        ngx.exit(403)
    end
    
    local payload = jwt_obj.payload
    
    -- Check if token has expired (using Asia/Manila timezone)
    local current_time = ngx.time() + (8 * 3600) -- Add 8 hours for Asia/Manila (UTC+8)
    if payload.exp and current_time > payload.exp then
        ngx.log(ngx.ERR, "Token has expired")
        ngx.status = 403
        ngx.say("Access denied: Token expired")
        ngx.exit(403)
    end
    
    -- Token is valid
    ngx.log(ngx.INFO, "JWT token validation successful, path: " .. path)
end



return _M
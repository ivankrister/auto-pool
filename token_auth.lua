-- token_auth.lua
-- HLS JWT Token Authentication for nginx with Laravel integration

local jwt = require "resty.jwt"
local cjson = require "cjson"

local _M = {}

-- Configuration - JWT secret should match your Laravel app's video_jwt_secret
local JWT_SECRET = os.getenv("VIDEO_JWT_SECRET") or "your-laravel-jwt-secret"

-- Function to get real client IP (handles Cloudflare and other proxies)
local function get_real_client_ip()
    -- Cloudflare provides the real client IP in CF-Connecting-IP header
    local cf_ip = ngx.var.http_cf_connecting_ip
    if cf_ip and cf_ip ~= "" then
        return cf_ip
    end
    
    -- Fallback to standard proxy headers
    local x_real_ip = ngx.var.http_x_real_ip
    if x_real_ip and x_real_ip ~= "" then
        return x_real_ip
    end
    
    -- X-Forwarded-For header (get first IP if multiple)
    local x_forwarded_for = ngx.var.http_x_forwarded_for
    if x_forwarded_for and x_forwarded_for ~= "" then
        local first_ip = string.match(x_forwarded_for, "([^,]+)")
        if first_ip then
            return string.gsub(first_ip, "%s+", "") -- trim whitespace
        end
    end
    
    -- Fallback to remote_addr (direct connection)
    return ngx.var.remote_addr
end

-- Function to validate JWT token
function _M.validate_token()
    local args = ngx.req.get_uri_args()
    local token = args["token"]
    local path = ngx.var.uri
    local client_ip = get_real_client_ip()
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
    
    -- Check if token has expired (using UTC)
    local current_time = ngx.time() -- UTC timestamp
    if payload.exp and current_time > payload.exp then
        ngx.log(ngx.ERR, "Token has expired. Current: " .. current_time .. ", Expires: " .. (payload.exp or "nil"))
        ngx.status = 403
        ngx.say("Access denied: Token expired")
        ngx.exit(403)
    end


    -- IP binding validation - ensure token is used from the same IP it was issued for
    if payload.ip and payload.ip ~= client_ip then
        ngx.log(ngx.ERR, "IP address mismatch. Token IP: " .. (payload.ip or "nil") .. ", Client IP: " .. client_ip .. 
                ", CF-IP: " .. (ngx.var.http_cf_connecting_ip or "none") .. 
                ", X-Real-IP: " .. (ngx.var.http_x_real_ip or "none") .. 
                ", X-Forwarded-For: " .. (ngx.var.http_x_forwarded_for or "none") .. 
                ", Remote: " .. ngx.var.remote_addr)
        ngx.status = 403
        ngx.say("Access denied: IP address mismatch")
        ngx.exit(403)
    end
    

end



return _M
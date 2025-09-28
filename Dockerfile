ARG ARCH

FROM ${ARCH}openresty/openresty:alpine AS dist

# Install required packages and Lua libraries for JWT authentication
RUN apk add --no-cache \
    git \
    perl \
    openssl-dev \
    curl

# Install lua-resty-jwt using opm (OpenResty Package Manager)
RUN /usr/local/openresty/bin/opm install ledgetech/lua-resty-http
RUN /usr/local/openresty/bin/opm install SkyLothar/lua-resty-jwt

# The environment variables for template (will be overridden by docker-compose.yml from .env)
ENV ORYX_SERVER=localhost:80 \
    VIDEO_JWT_SECRET=placeholder-secret \
    SRS_M3U8_EXPIRE=10 \
    SRS_TS_EXPIRE=3600

# Install gettext for envsubst
RUN apk add --no-cache gettext

# Copy configuration files
ADD nginx.edge.http.conf.template /tmp/nginx.template
ADD token_auth.lua /usr/local/openresty/lualib/token_auth.lua

# Create the proxy cache directory for NGINX.
RUN mkdir -p /data/nginx-cache

# Create a complete nginx.conf with our configuration
RUN echo 'worker_processes auto;' > /usr/local/openresty/nginx/conf/nginx.conf && \
    echo 'error_log /var/log/nginx/error.log warn;' >> /usr/local/openresty/nginx/conf/nginx.conf && \
    echo 'pid /var/run/nginx.pid;' >> /usr/local/openresty/nginx/conf/nginx.conf && \
    echo 'events { worker_connections 1024; }' >> /usr/local/openresty/nginx/conf/nginx.conf && \
    echo 'http {' >> /usr/local/openresty/nginx/conf/nginx.conf && \
    echo '    include /usr/local/openresty/nginx/conf/mime.types;' >> /usr/local/openresty/nginx/conf/nginx.conf && \
    echo '    default_type application/octet-stream;' >> /usr/local/openresty/nginx/conf/nginx.conf && \
    echo '    sendfile on;' >> /usr/local/openresty/nginx/conf/nginx.conf && \
    echo '    keepalive_timeout 65;' >> /usr/local/openresty/nginx/conf/nginx.conf && \
    echo '    include /etc/nginx/conf.d/*.conf;' >> /usr/local/openresty/nginx/conf/nginx.conf && \
    echo '}' >> /usr/local/openresty/nginx/conf/nginx.conf

# Add startup script
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'envsubst "\$ORYX_SERVER \$SRS_M3U8_EXPIRE \$SRS_TS_EXPIRE" < /tmp/nginx.template > /etc/nginx/conf.d/default.conf' >> /start.sh && \
    echo 'exec /usr/local/openresty/bin/openresty -g "daemon off;"' >> /start.sh && \
    chmod +x /start.sh

CMD ["/start.sh"]
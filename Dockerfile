ARG ARCH

FROM ${ARCH}nginx:latest AS dist

# The environment variables for template.
ENV ORYX_SERVER=10.104.0.3:80 \
    SRS_M3U8_EXPIRE=10 SRS_TS_EXPIRE=3600
ADD nginx.edge.http.conf.template /etc/nginx/templates/default.conf.template

# Create the proxy cache directory for NGINX.
RUN mkdir -p /data/nginx-cache
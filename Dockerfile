FROM nginx:1.31.9-alpine

# Remove default nginx config and page
RUN rm /etc/nginx/conf.d/default.conf /usr/share/nginx/html/*

# Custom nginx config: listen on 8080 (unprivileged), no server tokens
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy static site
COPY public/ /usr/share/nginx/html/

# Run as non-root
RUN chown -R nginx:nginx /usr/share/nginx/html /var/cache/nginx /var/log/nginx \
    && sed -i 's/^user  nginx;/# user  nginx;/' /etc/nginx/nginx.conf

USER nginx

EXPOSE 8080

# `wget` ships in nginx:alpine via busybox; -q for quiet, -O- discards body.
# Hits the root path so a misconfigured server (404 on /) is also caught.
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -q -O- http://127.0.0.1:8080/ >/dev/null 2>&1 || exit 1

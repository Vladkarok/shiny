FROM nginx:alpine

# Remove default nginx config and page
RUN rm /etc/nginx/conf.d/default.conf /usr/share/nginx/html/*

# Custom nginx config: listen on 8080 (unprivileged), no server tokens
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy static site
COPY index.html /usr/share/nginx/html/index.html

# Run as non-root
RUN chown -R nginx:nginx /usr/share/nginx/html /var/cache/nginx /var/log/nginx \
    && sed -i 's/^user  nginx;/# user  nginx;/' /etc/nginx/nginx.conf

USER nginx

EXPOSE 8080

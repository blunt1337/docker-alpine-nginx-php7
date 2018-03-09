# PHP 7 docker environement with alpine, nginx, php7

# Alpine base
FROM alpine:latest
MAINTAINER Olivier Blunt <contact@blunt.sh>

# Application file directory
ONBUILD ARG APP_DIR=/app

# Document root in the APP_DIR
ONBUILD ARG STATIC_DIR

# Service user
ONBUILD ARG USER=app

# Enable https (possible values: on, off, or force. Default off)
# Certificates must be stored as /etc/nginx/ssl/fullchain.pem and /etc/nginx/ssl/privkey.pem
ONBUILD ARG HTTPS=off

# Allowed domains, required for https (space separated)
ONBUILD ARG DOMAINS

# Server RAM (in MB) (default calculated at build time)
ONBUILD ARG RAM

# Maximum upload size (in MB)
ONBUILD ARG UPLOAD_MAX=10

# Enable a fail2ban like script (possible values: on, off, or manual. Default off)
ONBUILD ARG FAIL2BAN_ENABLED=off

# Fail2ban blacklist admin url
ONBUILD ARG FAIL2BAN_BLACKLIST_URL

# Fail2ban blacklist admin url auth user:password
ONBUILD ARG FAIL2BAN_BLACKLIST_BASIC_AUTH

# App files
ONBUILD WORKDIR $APP_DIR
#COPY index.php $APP_DIR/$STATIC_DIR/index.php

# Install
COPY install /install
#RUN /bin/sh /install/install.sh

# Run
EXPOSE 80 443
CMD ["runsvdir", "/etc/service"]
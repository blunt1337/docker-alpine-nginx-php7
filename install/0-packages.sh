#!/bin/bash
set -e

# Add testing packages
echo -e "
http://dl-cdn.alpinelinux.org/alpine/edge/main
http://dl-cdn.alpinelinux.org/alpine/edge/community
@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing
" >> /etc/apk/repositories

# Nginx
apk add --update nginx

# PHP
apk add --update php7@testing
apk add --update php7-fpm@testing
apk add --update php7-curl@testing
apk add --update php7-gd@testing
apk add --update php7-json@testing
apk add --update php7-opcache@testing
apk add --update php7-pdo_mysql@testing php7-mysqlnd@testing
apk add --update php7-mbstring@testing
apk add --update php7-session@testing
apk add --update php7-openssl@testing

# Runit
apk add --update runit@testing

# SSL
apk add --update openssl
apk add --update ca-certificates

# Clear
rm -rf /var/cache/apk/*
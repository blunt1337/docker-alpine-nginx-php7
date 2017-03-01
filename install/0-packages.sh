#!/bin/bash
set -e

# Add testing packages
echo -e "
http://dl-cdn.alpinelinux.org/alpine/edge/community
http://dl-cdn.alpinelinux.org/alpine/edge/main
@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing
" >> /etc/apk/repositories

# Update
apk upgrade -q -U -a

# Nginx
apk add --update nginx

# PHP
apk add --update php7
apk add --update php7-fpm
apk add --update php7-curl
apk add --update php7-gd
apk add --update php7-json
apk add --update php7-opcache
apk add --update php7-pdo_mysql php7-mysqlnd
apk add --update php7-mbstring
apk add --update php7-session
apk add --update php7-openssl

# Runit
apk add --update runit

# SSL
apk add --update openssl
apk add --update ca-certificates

# Clear
rm -rf /var/cache/apk/*
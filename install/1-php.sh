#!/bin/bash
set -e

# Packages
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

# PHP alias
if [ ! -f /usr/bin/php ]; then
    ln -s $(which php7) /usr/bin/php
fi

# PHP ini
echo "
short_open_tag = Off;
display_errors = Off;
allow_url_fopen = On;

max_execution_time = 60;
cgi.fix_pathinfo = 0;

session.use_trans_sid = 0;
session.use_only_cookies = 1;
session.hash_function = sha512;
session.hash_bits_per_character = 5;
session.entropy_file = /dev/urandom;
session.entropy_length = 256;
session.cookie_httponly = 1;

post_max_size = ${UPLOAD_MAX}M
upload_max_filesize = ${UPLOAD_MAX}M
max_file_uploads = ${UPLOAD_MAX}M
memory_limit = 64M
" >> /etc/php7/php.ini

# PHP fpm
max_threads=$(php -r "echo ceil($RAM / 64);")

echo "
[global]
emergency_restart_threshold = 3
emergency_restart_interval = 1m
process_control_timeout = 5s

[www]
listen = /var/run/php-fpm7.sock
listen.mode = 0666
listen.allowed_clients = 127.0.0.1

clear_env = no

user = $USER
group = $USER

pm = ondemand
pm.max_children = $max_threads
pm.process_idle_timeout = 15s
pm.max_requests = 200
" > /etc/php7/php-fpm.d/www.conf
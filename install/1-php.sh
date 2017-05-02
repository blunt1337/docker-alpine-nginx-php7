#!/bin/bash
set -e

# PHP ini
echo "
short_open_tag = Off;
display_errors = Off;
allow_url_fopen = On;

memory_limit = 32M;
post_max_size = 10M;
upload_max_filesize = 10M;
max_file_uploads = 10M;
max_execution_time = 60;
cgi.fix_pathinfo = 0;

session.use_trans_sid = 0;
session.use_only_cookies = 1;
session.hash_function = sha512;
session.hash_bits_per_character = 5;
session.entropy_file = /dev/urandom;
session.entropy_length = 256;
session.cookie_httponly = 1;
" >> /etc/php7/php.ini

# PHP fpm
echo "
[global]
emergency_restart_threshold = 3
emergency_restart_interval = 1m
process_control_timeout = 5s

[www]
listen = /var/run/php-fpm7.sock
listen.mode = 0666
listen.allowed_clients = 127.0.0.1" > /etc/php7/php-fpm.d/www.conf

# PHP alias
if [ ! -f /usr/bin/php ]; then
    ln -s $(which php7) /usr/bin/php
fi
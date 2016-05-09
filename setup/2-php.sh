#!/bin/bash
set -e

# php.ini changes
echo "
post_max_size = ${UPLOAD_MAX}M
upload_max_filesize = ${UPLOAD_MAX}M
memory_limit = 64M
" >> /etc/php7/php.ini

# php-fpm.conf changes
max_threads=$(php -r "echo ceil($RAM / 64);")

echo "
clear_env = off

user = $USER
group = $USER

pm = ondemand
pm.max_children = $max_threads
pm.process_idle_timeout = 15s
pm.max_requests = 200
" >> /etc/php7/php-fpm.d/www.conf
# php.ini changes
echo "
post_max_size = ${UPLOAD_MAX}M
upload_max_filesize = ${UPLOAD_MAX}M
memory_limit = 64M
" >> /etc/php7/php.ini

# php-fpm.conf changes
max_threads=$(php -r "echo ceil($RAM / 32);")
min_idle_threads=$(php -r "echo ceil($max_threads * 0.1);")
max_idle_threads=$(php -r "echo ceil($max_threads * 0.5);")

echo "
clear_env = off

user = $USER
group = $USER

pm = dynamic
pm.status_path = /php_fpm_status
pm.max_children = $max_threads
pm.start_servers = $min_idle_threads
pm.min_spare_servers = $min_idle_threads
pm.max_spare_servers = $max_idle_threads
pm.max_requests = 1000" >> /etc/php7/php-fpm.d/www.conf
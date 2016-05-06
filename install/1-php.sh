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
" >> /etc/php7/php.ini

# PHP fpm
echo "
[global]
emergency_restart_threshold = 10
emergency_restart_interval = 1m
process_control_timeout = 10s

[www]
listen = /var/run/php-fpm7.sock
listen.mode = 0666
listen.allowed_clients = 127.0.0.1" > /etc/php7/php-fpm.d/www.conf

# PHP alias
ln -s $(which php7) /usr/bin/php
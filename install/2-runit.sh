#!/bin/bash
set -e

# Nginx service
mkdir /etc/service/nginx
echo "#!/bin/sh
exec 2>&1
exec /usr/sbin/nginx -c /etc/nginx/nginx.conf -g \"daemon off;\"" > /etc/service/nginx/run
chmod +x /etc/service/nginx/run

# Php service
mkdir /etc/service/php7
echo "#!/bin/sh
exec 2>&1
exec /usr/sbin/php-fpm7 -c /etc/php7/php.ini -y /etc/php7/php-fpm.conf --nodaemonize"  > /etc/service/php7/run
chmod +x /etc/service/php7/run
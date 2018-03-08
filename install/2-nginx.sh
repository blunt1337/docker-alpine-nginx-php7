#!/bin/bash
set -e

# Packages
apk add --update nginx
apk add --update openssl
apk add --update ca-certificates

# Create a defaut nginx configuration
max_threads=$(php -r "echo ceil($RAM / 4);")

echo "
user $USER $USER;
worker_processes auto;
worker_rlimit_nofile 8192;

events {
	worker_connections $max_threads;
}

http {
	include		/etc/nginx/mime.types;
	include		/etc/nginx/fastcgi.conf;
	
	index		index.php index.html index.htm;
	autoindex	off;
	
	default_type	text/html;
	error_log		/dev/stderr info;
	access_log		/dev/stdout;
	sendfile		off;
	tcp_nopush		on;
	server_tokens	off;
	
	# Gzip
	gzip on;
	gzip_disable \"msie6\";
	gzip_vary on;
	gzip_proxied any;
	gzip_comp_level 6;
	gzip_buffers 16 8k;
	gzip_http_version 1.1;
	gzip_min_length 256;
	gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript text/tab-separated-values text/csv image/svg+xml application/javascript;
	
	# woff2
	types {
    	application/font-woff2 woff2;
	}
	
	# Cache
	map \$sent_http_content_type \$cacheable_types {
		\"image/x-icon\"			\"max-age=604800\";		# 1 weak
		\"image/gif\"				\"max-age=2628000\";	# 1 month
		\"image/png\"				\"max-age=2628000\";	# 1 month
		\"image/jpg\"				\"max-age=2628000\";	# 1 month
		\"image/jpeg\"				\"max-age=2628000\";	# 1 month
		\"application/font-woff\"	\"max-age=31557600\";	# 1 year
		\"text/css\"				\"max-age=31557600\";	# 1 year
		\"application/javascript\"	\"max-age=31557600\";	# 1 year
		\"text/javascript\"			\"max-age=31557600\";	# 1 year
		default						\"max-age=0\";
	}
	
	# Temp folders
	client_max_body_size		${UPLOAD_MAX}m;
	client_body_buffer_size		128k;
	client_body_temp_path		/tmp/client_body_temp;
	fastcgi_temp_path			/tmp/fastcgi_temp;
	
	# Servers
	include /etc/nginx/servers/*.conf;
}" > /etc/nginx/nginx.conf

# Default nginx configuration
if [ ! -f /etc/nginx/servers/default.conf ]; then
	mkdir -p /etc/nginx/servers
	
	if [ "$HTTPS" == 'force' ]; then
		echo "
		server {
			listen 80 default_server;
			server_name _;
			return 444;
		}
		server {
			listen 80;
			server_name 127.0.0.1 $DOMAINS;
			
			location / {
	    		rewrite ^ https://\$host\$request_uri? permanent;
			}
		}
		server {
			listen 443 ssl http2;
			server_name $DOMAINS;
			
		" > /etc/nginx/servers/default.conf
	elif [ "$HTTPS" == 'on' ]; then
		echo "
		server {
			listen 80 default_server;
			server_name _;
			return 444;
		}
		server {
			listen 80;
			listen 443 ssl http2;
			server_name 127.0.0.1 $DOMAINS;
			
		" > /etc/nginx/servers/default.conf
	elif [ -z "$DOMAINS" ]; then
		echo "
		server {
			listen 80 default_server;
			
		" > /etc/nginx/servers/default.conf
	else
		echo "
		server {
			listen 80 default_server;
			server_name _;
			return 444;
		}
		server {
			listen 80;
			server_name 127.0.0.1 $DOMAINS;
			
		" > /etc/nginx/servers/default.conf
	fi
	
	# SSL params
	if [ "$HTTPS" == 'force' ] || [ "$HTTPS" == 'on' ]; then
		echo "
		ssl_certificate /etc/nginx/ssl/fullchain.pem;
		ssl_certificate_key /etc/nginx/ssl/privkey.pem;
		ssl_protocols TLSv1.1 TLSv1.2;
		ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';
		ssl_prefer_server_ciphers on;
		ssl_session_cache shared:SSL:10m;
		" >> /etc/nginx/servers/default.conf
		
		# Generate a selfsigned certificate to use as default
		mkdir -p /etc/nginx/ssl
		openssl req -new -newkey rsa:2048 -days 1 -nodes -x509 \
		    -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=blunt.sh" \
		    -keyout /etc/nginx/ssl/privkey.pem \
			-out /etc/nginx/ssl/fullchain.pem
	fi
	
	# Locations
	echo "
		root \"$APP_DIR/$STATIC_DIR\";
		
		# Php files
		location ~ \\.php\$ {
			try_files \$uri =404;
			fastcgi_pass unix:/var/run/php-fpm7.sock;
		}
		
		location = /favicon.ico { access_log off; log_not_found off; }
		location = /robots.txt  { access_log off; log_not_found off; }
		
		# Protection
		location ~ /\.(?!well-known).* {
			deny all;
		}
		
		location / {
			# Cache time
			add_header \"Cache-Control\" \$cacheable_types;
		}
		
		add_header X-Frame-Options \"SAMEORIGIN\";
		add_header X-XSS-Protection \"1; mode=block\";
		add_header X-Content-Type-Options \"nosniff\";
	}" >> /etc/nginx/servers/default.conf
fi

# Rename SERVER_SOFTWARE
sed -i -r 's/(fastcgi_param\s+SERVER_SOFTWARE\s+).*;/\1blunt.sh;/g' /etc/nginx/fastcgi.conf

# Nginx pid file
mkdir /run/nginx
chown $USER:$USER /run/nginx
chmod 770 /run/nginx
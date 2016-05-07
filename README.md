# VirtualGarden/nginx-php7

This is a base [Docker image](https://www.docker.com/) to use as a web server with Nginx and PHP 7.
Nginx and PHP are both preconfigured and ready to handle your connection.

PHP include the following modules:
* json
* gd
* curl
* opcache
* pdo_mysql
* mbstring
* session
* openssl

## Simple usage
Create a Dockerfile in your project with the simple content
```Dockerfile
FROM virtualgarden/nginx-php7
COPY . /app
```
then [build](https://docs.docker.com/v1.8/reference/commandline/build/) and [run](https://docs.docker.com/engine/reference/commandline/run/) your container

## Custom usage
To customize the base image, you can change the base to `FROM virtualgarden/nginx-php7:onbuild`
and put a `config.sh` file with the following customizable code:
```sh
# Application file directory
# (add WORKDIR /xxx and CMD mv -R /app /xxx in your dockerfile to make it work)
APP_DIR="/app"

# Service user
USER="app"

# Document root in the APP_DIR
STATIC_DIR="static"

# Server RAM
RAM="512"

# Maximum upload size in Megabytes
UPLOAD_MAX="10"

# SSH password
# (add EXPOSE 22 to make it work)
USER_PASSWORD=""
```

## I need more PHP modules
To install additionnal modules, let's say sqlite, go to [alpine packages](https://pkgs.alpinelinux.org/packages) and search for php7*sqlite. You will find `php7-pdo_sqlite`. Just add the line `CMD apk add --update php7-pdo_sqlite@testing` inside your Dockerfile to install it.

## I want to change nginx configuration
All nginx server configuration blocks are stored in `/etc/nginx/servers/*.conf`. If you want to edit the default configuration, or add another one, create a file in your project like this one:
```Nginx
server {
	listen 80 default_server;
	root "/app";
	
	# Php files
	location ~ \\.php\$ {
		try_files $uri /index.php?url=$uri&$args;
		fastcgi_pass unix:/var/run/php-fpm7.sock;
	}
	
	location / {
		# Cache time
		add_header "Cache-Control" $cacheable_types;
	}
}
```
then add in your Dockerfile `COPY my_custom.conf /etc/nginx/servers/default.conf`.
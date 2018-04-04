<banner></banner>

---

<h1 menu-ignore>blunt1337/nginx-php7</h1>

This is a [Docker image](https://www.docker.com/) used as a web server with Nginx and PHP 7.1.

## Features:
- Nginx
- Php 7.1
- Small size, based on [alpine linux](https://alpinelinux.org)
- Preconfigured
- Nginx conf architecture, to have an extendable nginx configuration (add location, etc), without rewriting the full configuration,
- A script to ban ips when they have to many 401 status
- Configurable IP countries

## Simple usage
Just start it with `docker run -d -p 80:80 -v ${PWD}:/app blunt1337/nginx-php7` to use the current path as webroot.

PHP includes the following modules:
* json
* gd
* curl
* opcache
* pdo_mysql
* mbstring
* session
* openssl

## Adding rules to Nginx
You can add configuration files by extending the image with a Dockerfile:
```Dockerfile
FROM blunt1337/nginx-php7

# To add a location rule
COPY locations.conf /etc/nginx/locations/01-first-location.conf

# Or to fully override the default server block
COPY server.conf /etc/nginx/servers/default.conf
```

#### Following folders include \*.conf files automatically:
|   |   |
|---|---|
| /etc/nginx/modules | included at the start of the root nginx configuration |
| /etc/nginx/servers | included at the end of the http block |
| /etc/nginx/locations | included at the start of the server block, for normal requests |
| /etc/nginx/locations/no_domain | included at the start of the server block, for requests with no server_name match |
| /etc/nginx/locations/http | included at the start of the server block, for http requests only with HTTPS=force |

To print and debug your Nginx configuration, you can run ```docker exec <container_name> nginx -T```.

---

## Build arguments
To use the following build arguments, you need to extend the onbuild image. A full example is available at [nginx-php7-laravel](https://github.com/blunt1337/docker-alpine-nginx-php7-laravel).

```Dockerfile
# Onbuild image
FROM blunt1337/nginx-php7:onbuild

# Changed build args
ARG STATIC_DIR=public

# Run installation
RUN /bin/sh /install/install.sh
```

##### APP_DIR
Application file directory, default is /app.

##### STATIC_DIR
Document root in APP_DIR.
With STATIC_DIR=public, the url http://host/ will fetch /$APP_DIR/public/index.php.
Default is APP_DIR root.

##### USER
User and group running nginx/php process.
Default is 'app'.

##### HTTPS
Possible values are:
- off: Only listen for http.
- on: Listen for http and https.
- force: Listen for http and https, and redirect http to https.

Default is off. Certificates must be placed as `/etc/nginx/ssl/fullchain.pem` and  `/etc/nginx/ssl/privkey.pem`.

##### DOMAINS
List of allowed domains. Space separated. Default is all. Required for the https to work.

##### RAM
Server RAM in MB to calculate worker numbers, etc. Be default it will take the builder's machine max RAM.

##### UPLOAD_MAX
Maximum upload file size in MB, default is 10MB.

##### FAIL2BAN_ENABLED
Enable a fail2ban like script, in lua (NOT the real fail2ban with iptable), inside the nginx conf.  
After 5 times 401 response code, the ip address is banned, and only 503 response code are returned.  
Possible values are:
- on: enabled on every pages, catch every 401 everywhere,
- off: disabled,
- manual: insert "include /etc/nginx/fail2ban/check.conf" in locations you want protect.
Default is off.

##### FAIL2BAN_BLACKLIST_URL
Fail2ban blacklist admin url, used as a Nginx "location $here {", so you can use regex, for example "~ /bl[ao]cklist".  
To insert it manually, without any auth protection: "include /etc/nginx/fail2ban/api.conf".

##### FAIL2BAN_BLACKLIST_BASIC_AUTH
Fail2ban blacklist admin url's auth, in format user:password.

##### COUNTRY_WHITELIST / COUNTRY_BLACKLIST
Prevent/allow access from some countries. Space separated country codes.
For example to block top 10 hacker countries use `COUNTRY_BLACKLIST=CN US TR RU TW BR RO IN IT HU`. To whitelist local ips and France use `COUNTRY_WHITELIST=FR ''`

---

## Add PHP modules or rules
First create a new shell script file, to run files in order we prefix them with a number, for example `01-laravel.sh`:
```bash
#!/bin/bash
set -e

# Install some php extension
apk add --update php7-tokenizer
apk add --update php7-xml
apk add --update php7-zlib
apk add --update php7-ctype
apk add --update php7-fileinfo
apk add --update php7-sockets
apk add --update php7-dom

# Add the rewrite rules
echo '
location / {
	try_files $uri /index.php?$query_string;
}
error_page 404 /index.php;
' > /etc/nginx/locations/90-laravel.conf
```

Then create a Dockerfile:
```Dockerfile
FROM blunt1337/nginx-php7:onbuild

# Change webroot directory
ARG STATIC_DIR=public

# Add install scripts
COPY ??-*.sh /install/

# Run installation
RUN /bin/sh /install/install.sh
```










<script>
import Banner from 'js/components/banner'

export default {
	components: {
		Banner,
	}
}
</script>
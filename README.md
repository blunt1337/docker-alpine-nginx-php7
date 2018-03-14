# blunt1337/nginx-php7

[![](https://images.microbadger.com/badges/image/blunt1337/nginx-php7.svg)](https://microbadger.com/images/blunt1337/nginx-php7)

This is a [Docker image](https://www.docker.com/) to use as a web server with Nginx and PHP 7.1.  
Nginx and PHP are both preconfigured and ready to handle your connections.

PHP includes the following modules:
* json
* gd
* curl
* opcache
* pdo_mysql
* mbstring
* session
* openssl

## Simple usage
Just start it with `docker run -d -p 80:80 -v .:/app blunt1337/nginx-php7 ` to use the current path as webroot.

## I want to add rules in the nginx configuration
Following folders include *.conf files automatically:
- /etc/nginx/modules: included at the start of the root nginx configuration,
- /etc/nginx/servers: included at the end of the http block,
- /etc/nginx/locations: included at the start of the server block, for normal requests,
- /etc/nginx/locations/no_domain: included at the start of the server block, for requests with no server_name match,
- /etc/nginx/locations/http: included at the start of the server block, for http requests only with HTTPS=force.

To print and debug your nginx configuration, you can simply run `docker exec <container_name> nginx -T`.

## I want to change the full nginx configuration
All nginx server configuration blocks are stored in `/etc/nginx/servers/*.conf`. If you want to edit the default configuration, or add another one, create a file in your project like this one:
```Nginx
server {
	listen 80 default_server;
	root "/app";
	
	...
}
```
then add in your Dockerfile `COPY my_custom.conf /etc/nginx/servers/default.conf`.

## More custom usage
To extends the image, use the onbuild version that runs the install files in the extended image. E.g. the sample project [nginx-php7-laravel](https://github.com/blunt1337/docker-alpine-nginx-php7-laravel).  
A minimalistic Dockerfile to change the STATIC_DIR would be:
```dockerfile
FROM blunt1337/nginx-php7:onbuild
ARG STATIC_DIR=public
RUN /bin/sh /install/install.sh
```

The following configurations can be changed with [build args](https://docs.docker.com/compose/compose-file/#args):

##### APP_DIR
Application file directory, default to /app

##### STATIC_DIR
Document root in APP_DIR.  
With STATIC_DIR=public, the url http://host/ will fetch /app/public/index.php.  
Default to APP_DIR root.

##### USER
User and group running nginx/php process

##### HTTPS
Possible values are:
- off: Only listen for http.
- on: Listen for http and https.
- force: Listen for http and https, and redirect http to https.

Certificates must be placed as `/etc/nginx/ssl/fullchain.pem` and  `/etc/nginx/ssl/privkey.pem`.

##### DOMAINS
List of allowed domains. Space separated. Default to all. Required for the https to work.

##### RAM
Server RAM in MB to calculate worker numbers, etc. Be default it will take the builder's machine max RAM.

##### UPLOAD_MAX
Maximum upload file size in MB, default to 10MB

##### FAIL2BAN_ENABLED
Enable a fail2ban like script in lua (NOT the real fail2ban with iptable), inside the nginx conf.  
After 5 401 response code, the ip address is banned, and only 503 response code are returned.  
Possible values are:
- on: enabled on every pages, catch every 401 everywhere,
- off: disabled,
- manual: insert "include /etc/nginx/fail2ban/check.conf" in locations you want protect.
Default to off.

##### FAIL2BAN_BLACKLIST_URL
Fail2ban blacklist admin url, used as nginx "location $here {", so you can use regex, e.g. "~ /bl[ao]cklist".  
To insert it manually: "include /etc/nginx/fail2ban/api.conf".

##### FAIL2BAN_BLACKLIST_BASIC_AUTH
Fail2ban blacklist admin url's auth, in format user:password.

##### COUNTRY_WHITELIST / COUNTRY_BLACKLIST
Prevent/allow access from some countries. Space separated country codes.  
E.g. to block top 10 hacker countries use `COUNTRY_BLACKLIST=CN US TR RU TW BR RO IN IT HU`. To whitelist local ips and France use `COUNTRY_WHITELIST=FR ''`
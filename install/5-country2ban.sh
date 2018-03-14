#!/bin/sh
set -e

# Stop here if country2ban is not wanted
[ -z "$COUNTRY_WHITELIST" ] && [ -z "$COUNTRY_BLACKLIST" ] && exit 0

# Check param
if [ -n "$COUNTRY_WHITELIST" ] && [ -n "$COUNTRY_BLACKLIST" ]; then
	echo 'Only $COUNTRY_WHITELIST or $COUNTRY_BLACKLIST can be defined, not both.' >&2
	exit 1
fi

# Package
apk add --update nginx-mod-http-geoip

# Geo ip database
oldpath=$(pwd)
mkdir /etc/geoip
cd /etc/geoip
wget -q http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz
gunzip GeoIP.dat.gz
cd $oldpath

# Generate country list code
if [ -n "$COUNTRY_WHITELIST" ]; then
	clist=$(echo "$COUNTRY_WHITELIST" | sed -E "s/[^A-Z']+/ yes; /g")
	clist=$(echo "default no; $clist yes;")
else
	clist=$(echo "$COUNTRY_BLACKLIST" | sed -E "s/[^A-Z']+/ no; /g")
	clist=$(echo "default yes; $clist no;")
fi

# Nginx conf
echo "geoip_country /etc/geoip/GeoIP.dat;
map \$geoip_country_code \$allowed_country {
	$clist
}" > /etc/nginx/servers/5-country2ban.conf

echo "if (\$allowed_country = no) {
	return 444;
}" > /etc/nginx/locations/0-country2ban.conf
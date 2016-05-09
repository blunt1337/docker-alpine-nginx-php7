#!/bin/bash
set -e

#--------------------------------------------------------------------
#-- Configuration
#--------------------------------------------------------------------

# Application file directory
# (add WORKDIR /xxx and CMD mv -R /app /xxx in your dockerfile to make it work)
APP_DIR="/app"

# Service user
USER="app"

# Document root in the APP_DIR
STATIC_DIR="static"

# Maximum upload size in Megabytes
UPLOAD_MAX="10"

# SSH password
# (add EXPOSE 22 to make it work)
USER_PASSWORD=""

# Server RAM
memory_limit=$(expr $(cat /sys/fs/cgroup/memory/memory.limit_in_bytes) / 1024 / 1024)
memory_free=$(free -m | awk 'NR==2{printf $2}')
RAM=$(($memory_limit > $memory_free ? $memory_free : $memory_limit))

# Load the child config
if [ -f /app/config.sh ]; then
	source /app/config.sh
	rm /app/config.sh
fi

# Allow acces to sub scripts
export APP_DIR USER STATIC_DIR RAM UPLOAD_MAX USER_PASSWORD

#--------------------------------------------------------------------
#-- Call sub scripts
#--------------------------------------------------------------------

cd "$(dirname "$0")"
for script in *; do
	if echo "$script" | grep -Eq "^[0-9]"; then
		/bin/sh "$script"
	fi
done

# Clean
rm -R "$(dirname "$0")"
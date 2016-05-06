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

# Server RAM
RAM="512"

# Maximum upload size in Megabytes
UPLOAD_MAX="10"

# SSH password
# (add EXPOSE 22 to make it work)
USER_PASSWORD=""

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
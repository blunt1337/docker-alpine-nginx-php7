#!/bin/bash
set -e

#--------------------------------------------------------------------
#-- Configuration
#--------------------------------------------------------------------

# Application file directory
export APP_DIR="/app"

# Service user
export USER="app"

# Document root in the APP_DIR
export STATIC_DIR="static"

# Server RAM
export RAM="512"

# Maximum upload size in Megabytes
export UPLOAD_MAX="10"

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
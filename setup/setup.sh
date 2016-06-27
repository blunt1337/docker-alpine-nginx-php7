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
export STATIC_DIR=""

# Server RAM
memory_limit=$(expr $(cat /sys/fs/cgroup/memory/memory.limit_in_bytes) / 1024 / 1024)
memory_free=$(free -m | awk 'NR==2{printf $2}')
export RAM=$(($memory_limit > $memory_free ? $memory_free : $memory_limit))

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
rm -rf /tmp/*
rm -f /app/Dockerfile
rm -rf "$(dirname "$0")"
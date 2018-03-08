#!/bin/bash
set -e

# Create the user
adduser -D -g "" "$USER"

# Check if the app dir exists, or create it
if [ ! -d "$APP_DIR" ]; then
	mkdir -p "$APP_DIR"
fi

# Fix app dir permissions
find "$APP_DIR" -type d -exec chmod 750 {} \;
find "$APP_DIR" -type f -exec chmod 640 {} \;
chown -R "$USER:$USER" "$APP_DIR"
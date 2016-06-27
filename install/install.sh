#!/bin/bash
set -e

# Call sub scripts
cd "$(dirname "$0")"
for script in *; do
	if echo "$script" | grep -Eq "^[0-9]"; then
		/bin/sh "$script"
	fi
done

# Clean
rm -rf /tmp/*
rm -r "$(dirname "$0")"
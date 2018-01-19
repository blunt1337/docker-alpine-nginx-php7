#!/bin/bash
set -e

# Default server RAM
if [ -z "$RAM" ]; then
	memory_limit=$(expr $(cat /sys/fs/cgroup/memory/memory.limit_in_bytes) / 1024 / 1024)
	memory_free=$(free -m | awk 'NR==2{printf $2}')
	export RAM=$(($memory_limit > $memory_free ? $memory_free : $memory_limit))
fi

# Call sub scripts
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
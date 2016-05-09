#!/bin/bash
set -e

if [ -n "$USER_PASSWORD" ]; then
	# Package
	apk add --update openssh
	rm -rf /var/cache/apk/*

	# User password
	echo "$USER:$USER_PASSWORD" | chpasswd
	unset USER_PASSWORD

	# Runit
	mkdir /etc/service/sshd
	echo "#!/bin/sh
	exec 2>&1
	exec /usr/sbin/sshd -D -e" > /etc/service/sshd/run
	chmod +x /etc/service/sshd/run

	# Generate keys
	ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
	ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
fi
#!/bin/bash
set -e

# Stop here if fail2ban is not wanted
[ "$FAIL2BAN_ENABLED" == 'on' ] || [ "$FAIL2BAN_ENABLED" == 'manual' ] || exit 0

# Param check
if [ -n "$FAIL2BAN_BLACKLIST_URL" ] && [ -z "$FAIL2BAN_BLACKLIST_BASIC_AUTH" ]; then
	echo "Missing parameter \$FAIL2BAN_BLACKLIST_BASIC_AUTH"
	exit 1
fi

# Package
apk add --update nginx-mod-http-lua

# Global http instruction
echo "lua_shared_dict blacklist 10m;
access_by_lua_no_postpone on;
$(cat /etc/nginx/servers/default.conf)" > /etc/nginx/servers/default.conf

# Include 'check/log' script in all server { .. }
if [ "$FAIL2BAN_ENABLED" == 'on' ]; then
	sed -i -e 's/server\s*{/\0\ninclude \/etc\/nginx\/fail2ban\/check.conf;\n/g' /etc/nginx/servers/default.conf
fi

# Include the api
if [ -n "$FAIL2BAN_BLACKLIST_URL" ]; then
	replace=$(echo "$FAIL2BAN_BLACKLIST_URL" | sed 's/[&/\]/\\&/g')
	sed -i -e "s/server\s*{/\0\nlocation $replace { auth_basic off; include \/etc\/nginx\/fail2ban\/api.conf; }\n/g" /etc/nginx/servers/default.conf
fi

# Check and log failed auth
mkdir /etc/nginx/fail2ban
cat <<'UNICORN' > /etc/nginx/fail2ban/check.conf
# Check the client IP address is in our blacklist
access_by_lua_block {
	local nb = ngx.shared.blacklist:get(ngx.var.remote_addr)
	if nb and nb > 5 then
		ngx.exit(ngx.HTTP_FORBIDDEN)
	end
}

# Register all failed auth
log_by_lua_block {
	--require "resty.core.shdict"
	if ngx.var.status == '401' then
		--ngx.shared.blacklist:incr(ngx.var.remote_addr, 1, 0, 43200) --12h
		ngx.shared.blacklist:incr(ngx.var.remote_addr, 1, 0)
	end
}
UNICORN

# Blacklist password
base64_password=$(echo -n "$FAIL2BAN_BLACKLIST_BASIC_AUTH" | base64)

# Insert the fail2ban/check script if manual
include=''
if [ "$FAIL2BAN_ENABLED" == 'manual' ]; then
	include="\ninclude /etc/nginx/fail2ban/check.conf;"
fi

# Auth code for the api
auth_lua=''
if [ -n "$FAIL2BAN_BLACKLIST_BASIC_AUTH" ]; then
	auth_lua="-- Auth
	if ngx.var.http_Authorization ~= 'Basic $base64_password' then
		ngx.header['WWW-Authenticate'] = 'Basic realm=\"Private url\"'
		ngx.exit(ngx.HTTP_UNAUTHORIZED)
	end"
fi

# Show/edit blacklist's page
cat <<UNICORN > /etc/nginx/fail2ban/api.conf
default_type 'text/html';
$include
content_by_lua_block {
	$auth_lua
	-- Remove a banned ip
	if ngx.req.get_method() == 'DELETE' then
		ngx.req.read_body()
		local success = ngx.shared.blacklist:set(ngx.req.get_body_data(), nil)
		ngx.exit(success and ngx.HTTP_OK or ngx.HTTP_NOT_FOUND)
	end
	
	-- Show the ban list
	ngx.say('<h3>Blacklisted IPs</h3>')
	ngx.say([[<script type="text/javascript">
		function removeip(a, ip) {
			var ajax = new XMLHttpRequest();
			ajax.onreadystatechange = function() {
				if (ajax.readyState == 4) {
					if (ajax.status == 200) {
						a.parentNode.removeChild(a);
					} else {
						alert('Result code: ' + ajax.status);
					}
				}
			};
			ajax.open('DELETE', window.location.href, true);
			ajax.send(ip);
		}
		</script>
		<style>
		body {
			max-width: 800px;
			margin: 2em auto 0;
		}
		</style>]])
	
	local blacklist = ngx.shared.blacklist
	local ips = blacklist:get_keys(0)
	for _, ip in ipairs(ips) do
		if blacklist:get(ip) > 5 then
			ngx.say('<div>')
			ngx.say('<a target="_blank" href="https://tools.keycdn.com/geo?host=' .. ip .. '">' .. ip .. '</a>')
			ngx.say(' <a href="javascript:void(0)" onclick="removeip(this.parentNode, \'' .. ip .. '\')">unban</a>')
			ngx.say('</div>')
		end
	end
}
UNICORN
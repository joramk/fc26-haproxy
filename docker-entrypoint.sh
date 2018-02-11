#!/bin/bash
set -eo pipefail
shopt -s nullglob

setup() {
        if [ ! -z "$SELFUPDATE" ]; then
		sed -i 's/apply_updates = no/apply_updates = yes/g' /etc/yum/yum-cron.conf
                systemctl enable yum-cron
                yum update -y
        fi

        if [ ! -z "$TIMEZONE" ]; then
                ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
        fi

	if [ ! -z "$HAPROXY_LETSENCRYPT_OCSP" ] && [ ! -z "$HAPROXY_LETSENCRYPT" ]; then
		echo "0 5 * * * root /usr/local/sbin/certbot-ocsp >/dev/null" >/etc/cron.d/certbot-ocsp
	fi

	if [ ! -z "$HAPROXY_LETSENCRYPT" ]; then
		echo "45 4 * * 0 root /usr/local/sbin/certbot-renew >/dev/null" >/etc/cron.d/certbot-renew
		unset IFS
		domains=()
		for var in $(compgen -e); do
		        if [[ "$var" =~ LETSENCRYPT_DOMAIN_.* ]]; then
        		        domains+=( "${!var}" )
		        fi
		done
		for entry in "${domains[@]}"; do
        		array=(${entry//,/ })
        		/usr/local/sbin/certbot-issue ${array[@]}
		done
        fi	
}

if [ -e /firstrun ] && [ -z "$OMIT_FIRSTRUN" ]; then      
        setup
        rm -f /firstrun
fi

exec "$@"

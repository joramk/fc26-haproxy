FROM    joramk/fc26-base
MAINTAINER joramk@gmail.com
ENV     container docker

LABEL   name="Fedora - HAproxy with Lets Encrypt" \
        vendor="https://github.com/joramk/fc26-haproxy" \
        license="none" \
        build-date="20171006" \
        maintainer="joramk" \
	issues="https://github.com/joramk/fc26-haproxy/issues"

RUN {   yum install --enablerepo=updates-testing haproxy-1.7.9 certbot cronie procps-ng iputils socat yum-cron -y; \
        yum clean all && rm -rf /var/cache/yum; \
}

COPY    ./docker-entrypoint.sh /
COPY    ./certbot-issue ./certbot-ocsp ./certbot-renew /usr/local/sbin/

RUN {	systemctl enable haproxy crond; \
	systemctl disable auditd; \
	touch /firstrun; \
	chmod +rx /docker-entrypoint.sh; \
	chmod 700 /usr/local/sbin/certbot-{issue,ocsp,renew}; \
	mkdir -p /etc/letsencrypt/live; \
	sed -i 's/#ForwardToConsole=no/ForwardToConsole=yes/g' /etc/systemd/journald.conf; \
}

HEALTHCHECK CMD systemctl -q is-active haproxy || exit 1
STOPSIGNAL SIGRTMIN+3
EXPOSE 80 443
VOLUME [ “/sys/fs/cgroup”, "/etc/haproxy", "/etc/letsencrypt" ]
ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "/sbin/init" ]

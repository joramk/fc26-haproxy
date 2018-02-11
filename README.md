Fedora 26 HAProxy docker image with Let´s Encrypt [![Build Status](https://travis-ci.org/joramk/fc26-haproxy.svg?branch=haproxy-1.7.9)](https://travis-ci.org/joramk/fc26-haproxy)
===
A Fedora 26 based HAProxy docker image with Let´s Encrypt support in different version flavours.

Tags
==
Tag | Description
---|---
latest | Installs HAProxy v1.7.9 (stable)
**1.7.9** | **Installs HAProxy v1.7.9 (stable)**   
1.7.3 | Installs HAProxy v1.7.3 (old)   

Features
==
* Self update through Fedora package management
* Latest Fedora with full systemd
* Integrated LetsEncrypt with automatic issueing and update of certificates 

Environment variables
===
Variable | Description
---|---
TIMEZONE | Sets the container timezone, i.e. `-e TIMEZONE=Europe/Berlin` _string_
SELFUPDATE | Activates the Fedora base system package selfupdate _boolean_
HAPROXY_LETSENCRYPT | Activates the LetsEncrypt components and installs the renewal cronjob _boolean_
HAPROXY_LETSENCRYPT_OCSP | Activates OCSP stapling and the daily update cronjob _boolean_
LETSENCRYPT\_DOMAIN\_\* | Issues a certificate from LetsEncrypt, i.e. `-e LETSENCRYPT_DOMAIN_1=www.example.org,mail@example.org`

General first run configuration
===
~~~
docker run -ti -p 80:80 -p 443:443 \
    --tmpfs /run --tmpfs /tmp \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
    -e "TIMEZONE=Europe/Berlin" \
    -e "SELFUPDATE=1" \
    -e "HAPROXY_LETSENCRYPT=1" \
    -e "HAPROXY_LETSENCRYPT_OCSP=1" \
    -e "LETSENCRYPT_DOMAIN_1=www.example.org,someone@example.org"
    -e "LETSENCRYPT_DOMAIN_2=www.example.com,anyone@example.com"
    joramk/fc26-haproxy:latest
~~~

Docker swarm
==
    docker service create -d --log-driver=journald -p 80:80 -p 443:443 --replicas 2 \
        --mount type=tmpfs,dst=/run --mount type=tmpfs,dst=/tmp \
        --mount type=bind,src=/sys/fs/cgroup,dst=/sys/fs/cgroup,ro \
        -e "TIMEZONE=Europe/Berlin" \
        -e "SELFUPDATE=1" \
        -e "HAPROXY_LETSENCRYPT=1" \
        -e "HAPROXY_LETSENCRYPT_OCSP=1" \
        -e "LETSENCRYPT_DOMAIN_1=www.example.org,someone@example.org"
        -e "LETSENCRYPT_DOMAIN_2=www.example.com,anyone@example.com"
        joramk/fc26-haproxy:latest

My own configuration
==
~~~
docker run -d \
    --tmpfs /run --tmpfs /tmp \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
    -v /etc/docker/letsencrypt:/etc/letsencrypt:Z \
    -v /etc/docker/haproxy:/etc/haproxy:Z \
    --network web --ip 172.18.0.2 --hostname=proxy1.docker1.dmz.lonet.org \
    --name proxy1_c --network-alias proxy1.docker1.dmz.lonet.org \
    --dns-search docker1.dmz.lonet.org --dns-search dmz.lonet.org \
    --network-alias jira.lonet.org --network-alias confluence.lonet.org \
    --network-alias git.lonet.org --network-alias lonet.org \
    --network-alias www.lonet.org \
    -e "TIMEZONE=Europe/Berlin" \
    -e "SELFUPDATE=1" \
    -e "HAPROXY_LETSENCRYPT=1" \
    -e "HAPROXY_LETSENCRYPT_OCSP=1" \
    -e "LETSENCRYPT_DOMAIN_1=jira.lonet.org,joramk@gmail.com"
    -e "LETSENCRYPT_DOMAIN_2=confluence.lonet.org,joramk@gmail.com"
    -e "LETSENCRYPT_DOMAIN_3=git.lonet.org,joramk@gmail.com"
    joramk/fc26-haproxy:latest
~~~

Issue and update certificates manually
==
    docker exec -ti <container> certbot-issue <domain.tld> <email>
    docker exec -ti <container> certbot-renew

Found a bug?
==
Please report issues on GitHub: https://github.com/joramk/fc26-haproxy/issues


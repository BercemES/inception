#!/bin/sh

if [ ! -f /etc/nginx/ssl/bekinci-.42.fr.crt ]; then
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/bekinci-.42.fr.key \
    -out /etc/nginx/ssl/bekinci-.42.fr.crt \
    -subj "/CN=bekinci-.42.fr"
fi

exec nginx -g 'daemon off;'
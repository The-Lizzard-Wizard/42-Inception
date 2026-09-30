#!/bin/bash
mkdir -p /etc/nginx/ssl/

if [ ! -f /etc/nginx/ssl/inception.crt ]; then
    openssl req -x509 -newkey rsa:2048 -nodes -days 365 \
        -keyout /etc/nginx/ssl/inception.key \
        -out /etc/nginx/ssl/inception.crt \
        -subj "/C=FR/ST=AURA/L=Lyon/O=42/CN=${DOMAIN_NAME}"
fi

exec nginx -g "daemon off;"
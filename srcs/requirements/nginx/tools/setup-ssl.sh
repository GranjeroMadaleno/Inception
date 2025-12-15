#!/bin/bash

set -e

# Kolorintxis

BLACK='\033[30m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'
WHITE='\033[37m'

echo -e "${CYAN}[NGINX] Konfigurazioa abiarazten...${WHITE}"

# SSL ziurtagiriak lehendik badauden egiaztatzea

if [ ! -f /etc/nginx/ssl/nginx.crt ] || [ ! -f /etc/nginx/ssl/nginx.key ]; then
    echo -e "${CYAN}[NGINX] SSL ziurtagiri autofirmatuak sortzen...${WHITE}"
    
    # Sortu SSL ziurtagiri autofirmatua

    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/nginx.key \
        -out /etc/nginx/ssl/nginx.crt \
        -subj "/C=ES/ST=Madrid/L=Madrid/O=42/OU=Student/CN=${DOMAIN_NAME}"
    
    # Baimenak ezarri

    chmod 600 /etc/nginx/ssl/nginx.key
    chmod 644 /etc/nginx/ssl/nginx.crt
    
    echo -e "${GREEN}[NGINX] SSL ziurtagiriak behar bezala sortu egin dira${WHITE}"
else
    echo -e "${GREEN}[NGINX] SSL ziurtagiriak dagoeneko existitzen dira${WHITE}"
fi

echo -e "${GREEN}[NGINX] NGINX abiarazten...${WHITE}"

# NGINX lehenengo planoan abiarazi (PID 1)

exec nginx -g 'daemon off;'

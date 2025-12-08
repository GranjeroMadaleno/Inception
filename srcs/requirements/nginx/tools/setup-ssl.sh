#!/bin/bash

set -e

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}[NGINX] Iniciando configuración...${NC}"

# Verificar si los certificados SSL ya existen
if [ ! -f /etc/nginx/ssl/nginx.crt ] || [ ! -f /etc/nginx/ssl/nginx.key ]; then
    echo -e "${BLUE}[NGINX] Generando certificados SSL autofirmados...${NC}"
    
    # Generar certificado SSL autofirmado
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/nginx.key \
        -out /etc/nginx/ssl/nginx.crt \
        -subj "/C=ES/ST=Madrid/L=Madrid/O=42/OU=Student/CN=${DOMAIN_NAME}"
    
    # Establecer permisos
    chmod 600 /etc/nginx/ssl/nginx.key
    chmod 644 /etc/nginx/ssl/nginx.crt
    
    echo -e "${GREEN}[NGINX] Certificados SSL generados correctamente${NC}"
else
    echo -e "${GREEN}[NGINX] Certificados SSL ya existen${NC}"
fi

echo -e "${GREEN}[NGINX] Iniciando NGINX...${NC}"

# Iniciar NGINX en primer plano (PID 1)
exec nginx -g 'daemon off;'

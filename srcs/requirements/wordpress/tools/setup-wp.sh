#!/bin/bash

set -e

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo -e "${BLUE}[WordPress] Iniciando configuración...${NC}"

# Leer contraseña de DB desde Docker Secrets
if [ -f /run/secrets/db_password ]; then
    MYSQL_PASSWORD=$(cat /run/secrets/db_password)
    echo -e "${GREEN}[WordPress] Contraseña de DB cargada desde secrets${NC}"
else
    echo "Error: Secret db_password no encontrado"
    exit 1
fi

# Leer contraseñas de WordPress desde Docker Secrets
if [ -f /run/secrets/wp_admin_password ]; then
    WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
    echo -e "${GREEN}[WordPress] Contraseña de admin cargada desde secrets${NC}"
else
    echo "Error: Secret wp_admin_password no encontrado"
    exit 1
fi

if [ -f /run/secrets/wp_user_password ]; then
    WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)
    echo -e "${GREEN}[WordPress] Contraseña de usuario cargada desde secrets${NC}"
else
    echo "Error: Secret wp_user_password no encontrado"
    exit 1
fi

echo -e "${GREEN}[WordPress] Configuración de usuarios cargada desde .env y secrets${NC}"

# Esperar a que MariaDB esté listo
echo -e "${BLUE}[WordPress] Esperando a que MariaDB esté disponible...${NC}"
until mysql -h mariadb -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SELECT 1" &>/dev/null; do
    echo -e "${YELLOW}[WordPress] MariaDB no está listo aún... esperando${NC}"
    sleep 3
done
echo -e "${GREEN}[WordPress] MariaDB está listo${NC}"

# Cambiar al directorio de WordPress
cd /var/www/html

# Verificar si WordPress ya está instalado
if [ ! -f wp-config.php ]; then
    echo -e "${BLUE}[WordPress] Descargando WordPress...${NC}"
    
    # Descargar WordPress
    wp core download --allow-root
    
    echo -e "${BLUE}[WordPress] Creando wp-config.php...${NC}"
    
    # Crear configuración de WordPress
    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost=mariadb \
        --allow-root
    
    echo -e "${BLUE}[WordPress] Instalando WordPress...${NC}"
    
    # Instalar WordPress
    wp core install \
        --url="${WP_URL}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root
    
    echo -e "${BLUE}[WordPress] Creando segundo usuario...${NC}"
    
    # Crear segundo usuario (requisito del subject)
    wp user create \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --role=editor \
        --user_pass="${WP_USER_PASSWORD}" \
        --allow-root
    
    echo -e "${GREEN}[WordPress] WordPress instalado correctamente${NC}"
else
    echo -e "${GREEN}[WordPress] WordPress ya está instalado${NC}"
fi

# Cambiar permisos
chown -R www-data:www-data /var/www/html

echo -e "${GREEN}[WordPress] Iniciando PHP-FPM...${NC}"

# Iniciar PHP-FPM en primer plano (PID 1)
exec /usr/sbin/php-fpm8.2 -F

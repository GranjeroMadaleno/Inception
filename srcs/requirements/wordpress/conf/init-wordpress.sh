#!/bin/bash
set -e

# --- LECTURA DE VARIABLES Y SECRETOS ---
# Secretos existentes (Contraseñas)
DB_USER_PASS=$(cat /run/secrets/db_password)
ADMIN_PASS=$(cat /run/secrets/db_user)

# Variables de Entorno (Nombres, DB_NAME, y Emails)
MYSQL_HOST=mariadb
DB_NAME=${WORDPRESS_DB_NAME}
DB_USER=${MYSQL_USER}
ADMIN_USER=${MYSQL_USER_ADMIN}
DOMAIN_NAME=${DOMAIN_NAME}
WP_ADMIN_EMAIL=${WP_ADMIN_EMAIL}
WP_CONTRIB_USER=${WP_CONTRIB_USER}
WP_CONTRIB_EMAIL=${WP_CONTRIB_EMAIL}


echo "Esperando a que MariaDB (en ${MYSQL_HOST}) esté disponible..."
until nc -z -v -w30 ${MYSQL_HOST} 3306
do
  echo "⌛ Esperando base de datos..."
  sleep 2
done
echo "✅ Base de datos disponible!"

cd /var/www/html

# 1. Configuración del archivo wp-config.php (condicional)
if [ ! -f wp-config.php ]; then
  wp config create \
    --allow-root \
    --dbname="$DB_NAME" \
    --dbuser="$DB_USER" \
    --dbpass="$DB_USER_PASS" \
    --dbhost=mariadb \
    --skip-check

  echo "define('FS_METHOD', 'direct');" >> wp-config.php
fi

chown -R www-data:www-data /var/www/html

# 2. Instalación de WordPress y creación de usuarios (condicional)
if ! wp core is-installed --path=/var/www/html --allow-root; then
  echo "⚙️ Instalando WordPress..."

  # Instalación de WordPress (Usuario Admin)
  wp core install \
    --url="https://${DOMAIN_NAME}" \
    --title="Inception WordPress" \
    --admin_user="${ADMIN_USER}" \
    --admin_password="${ADMIN_PASS}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --path=/var/www/html \
    --skip-email \
    --allow-root

  # Crear segundo usuario (Colaborador)
  wp user create "${WP_CONTRIB_USER}" "${WP_CONTRIB_EMAIL}" \
    --role=contributor \
    --user_pass="${ADMIN_PASS}"             # Usa el mismo secreto para la contraseña del colaborador
    --allow-root \
    --path=/var/www/html
fi

echo "✅ Arrancando PHP-FPM..."
# 3. Lanzar PHP-FPM como PID 1 (CORRECCIÓN CRÍTICA)
exec /usr/sbin/php-fpm8.2 -F
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

echo -e "${CYAN}[WordPress] Konfigurazioa abiarazten...${WHITE}"

# Secrets karpetatik DB pasahitza irakurri
if [ -f /run/secrets/db_password ]; then
    MYSQL_PASSWORD=$(cat /run/secrets/db_password)
    echo -e "${GREEN}[WordPress] Secrets fitxategitik DB pasahitza kargatu da${WHITE}"
else
    echo "Error: Secrets db_password ezin izan da aurkitu X_X "
    exit 1
fi

# Secrets karpetatik WordPress pasahitza irakurri
if [ -f /run/secrets/wp_admin_password ]; then
    WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
    echo -e "${GREEN}[WordPress] Secrets fitxategitik administratzaile pasahitza kargatu da${WHITE}"
else
    echo "Error: Secret wp_admin_password ezin izan da aurkitu X_X"
    exit 1
fi

if [ -f /run/secrets/wp_user_password ]; then
    WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)
    echo -e "${GREEN}[WordPress] Secrets fitxategitik erabiltzaile pasahitza kargatu da${WHITE}"
else
    echo "Error: Secret wp_user_password ezin izan da aurkitu X_X"
    exit 1
fi

echo -e "${GREEN}[WordPress] .env eta secrets fitxategietatik kargatutako erabiltzaileen konfigurazioa${WHITE}"

# Itxoin MariaDB prest egon arte

echo -e "${CYAN}[WordPress] MariaDB erabilgarri egon arte itzoiten...${WHITE}"
until mysql -h mariadb -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SELECT 1" &>/dev/null; do
    echo -e "${MAGENTA}[WordPress] MariaDB oraindik ez dago prest... itzoiten${WHITE}"
    sleep 3
done
echo -e "${GREEN}[WordPress] MariaDB erabilgarri egon arte itzoiten${WHITE}"

# WordPress direktorian sartu

cd /var/www/html

# Egiaztatu WordPress instalatuta dagoen ala ez

if [ ! -f wp-config.php ]; then
    echo -e "${CYAN}[WordPress] WordPress deskargatzen...${WHITE}"
    
    # WordPress deskargatu

    wp core download --allow-root
    
    echo -e "${CYAN}[WordPress] wp-config.php sortzen...${WHITE}"
    
    # WordPress konfigurazioa sortu

    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost=mariadb \
        --allow-root
    
    echo -e "${CYAN}[WordPress] WordPress instalatzen...${WHITE}"
    
    # WordPress instalatu

    wp core install \
        --url="${WP_URL}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root
    
    echo -e "${CYAN}[WordPress] Bigarren erabiltzailea sortzen...${WHITE}"
    
    # Bigarren erabiltzailea sortu

    wp user create \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --role=editor \
        --user_pass="${WP_USER_PASSWORD}" \
        --allow-root
    
    echo -e "${GREEN}[WordPress] WordPress instalazioa ondo doa${WHITE}"
else
    echo -e "${GREEN}[WordPress] WordPress instalatu egin da${WHITE}"
fi

# Baimenak eraldatu

chown -R www-data:www-data /var/www/html

echo -e "${GREEN}[WordPress] PHP-FPM abiarazten...${WHITE}"

# PHP-FPM lehenengo planoan abiarazi (PID 1)

exec /usr/sbin/php-fpm8.2 -F

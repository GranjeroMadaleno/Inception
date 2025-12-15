#!/bin/bash

# Zerbait txarto badoa exit egiten du 

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

echo -e "${CYAN}[MariaDB] Konfigurzioa abiarazten...${WHITE}"

# Pasahitzak "secrets" karpetatik irakurri

if [ -f /run/secrets/db_root_password ]; then
    MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
    echo -e "${GREEN}[MariaDB] Secrets karpetatik root pasahitza kargatu egin da${WHITE}"
else
    echo "Error: Secret db_root_password ez da aurkitu"
    exit 1
fi

if [ -f /run/secrets/db_password ]; then
    MYSQL_PASSWORD=$(cat /run/secrets/db_password)
    echo -e "${GREEN}[MariaDB] Secrets karpetatik erabiltzaile pasahitza kargatu egin da${WHITE}"
else
    echo "Error: Secret db_password ez da aurkitu"
    exit 1
fi

# Ingurumena ondo kargatu egin dela egiaztatzen du

if [ -z "$MYSQL_ROOT_PASSWORD" ] || [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ]; then
    echo "Error: Ingurumen aldagaiak ez dira ezarri"
    exit 1
fi

# Lehenengo aldia bada, abiarazten du

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo -e "${CYAN}[MariaDB] Datu basea abiarazten...${WHITE}"
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# MariaDB aldi baterako abiarazten du konfigurazioa betetzeko

echo -e "${CYAN}[MariaDB] Aldi baterako zerbitzaria abiarazten (background-ean)...${WHITE}"
mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
                                                    pid="$!"

# MariaDB prest dagoenean abiarazten da

echo -e "${CYAN}[MariaDB] Zerbitzaria abiarazten...${WHITE}"
for i in {30..0}; do
    if mysqladmin ping --silent; then
        break
    fi
    sleep 1
done

if [ "$i" = 0 ]; then
    echo "Error: MariaDB ezin izan da abiarazi"
    kill "$pid"
    exit 1
fi

echo -e "${GREEN}[MariaDB] Aldi baterako zerbitzaria abiarazten${WHITE}"

# ERABILTZAILE ETA DATU BASEAREN KONFIGURAZIOA

if [ ! -d "/var/lib/mysql/$MYSQL_DATABASE" ]; then
    echo -e "${CYAN}[MariaDB] Datu basea konfiguratzen...${WHITE}"
    
    # Konfigurazio komandoak

    mysql -u root <<-EOSQL
        -- Root pasahita ezarri
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        
        -- Datu basea sortu
        CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
        
        -- Erabiltzaile eta abantailak ezarri
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
        
        -- Aldaketak ezarri
        FLUSH PRIVILEGES;
EOSQL
    
    echo -e "${GREEN}[MariaDB] Datu basea arazo barik konfiguratu da${WHITE}"
else
    echo -e "${GREEN}[MariaDB] Datu basea badago sortua, konfigurazioa sahiesten${WHITE}"
fi

# ALDI BATERAKO ZERBITZARIA GELDIARAZTEN ETA BUKAERA BIDALTZEN

# Aldi baterakeo mysqld prozezua erail 

echo -e "${CYAN}[MariaDB] Aldi baterako zerbitzaria geldiarazten...${WHITE}"
kill "$pid"

# Prozezua bukatzean hurrengoa abiatzen da
# error 502 madarikatua sahiesteko balio du 

wait "$pid" 2>/dev/null || : 

echo -e "${GREEN}[MariaDB] Lehenengo plano-ko azken zerbitzaria abiarazten...${WHITE}"

# Lehenengo atalean MariaDB abiarazi (PID 1)

exec mysqld --user=mysql --datadir=/var/lib/mysql
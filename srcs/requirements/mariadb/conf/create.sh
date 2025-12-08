#!/bin/bash
echo ">>> Generando create.sql con parámetros recibidos" >&2

# Root erabiltzailearen konfigurazioa
cat <<EOF
-- Configurar usuario root
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
EOF

# datu basearen sormena
if [ -n "$MYSQL_DATABASE" ]; then
    cat <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
EOF
fi

# erabiltzaile betegarria sortu ta baimenak ezarri
if [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ]; then
    cat <<EOF
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
fi

# Skript bukaera
cat <<EOF
FLUSH PRIVILEGES;
EOF
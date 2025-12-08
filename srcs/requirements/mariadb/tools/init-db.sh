#!/bin/bash

# si algo falla del script, se detiene
set -e 

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}[MariaDB] Iniciando configuración...${NC}"

# Leer contraseñas desde Docker Secrets
if [ -f /run/secrets/db_root_password ]; then
    MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
    echo -e "${GREEN}[MariaDB] Contraseña root cargada desde secrets${NC}"
else
    echo "Error: Secret db_root_password no encontrado"
    exit 1
fi

if [ -f /run/secrets/db_password ]; then
    MYSQL_PASSWORD=$(cat /run/secrets/db_password)
    echo -e "${GREEN}[MariaDB] Contraseña de usuario cargada desde secrets${NC}"
else
    echo "Error: Secret db_password no encontrado"
    exit 1
fi

# Verificar que las variables de entorno estén definidas
if [ -z "$MYSQL_ROOT_PASSWORD" ] || [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ]; then
    echo "Error: Variables de entorno no definidas"
    exit 1
fi

# Inicializar si es la primera vez
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo -e "${BLUE}[MariaDB] Inicializando base de datos...${NC}"
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Iniciar MariaDB temporalmente para configuración
echo -e "${BLUE}[MariaDB] Iniciando servidor temporal (en background)...${NC}"
mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
pid="$!"

# Esperar a que MariaDB esté listo
echo -e "${BLUE}[MariaDB] Esperando a que el servidor esté listo...${NC}"
for i in {30..0}; do
    if mysqladmin ping --silent; then
        break
    fi
    sleep 1
done

if [ "$i" = 0 ]; then
    echo "Error: MariaDB no pudo iniciarse"
    kill "$pid"
    exit 1
fi

echo -e "${GREEN}[MariaDB] Servidor temporal listo${NC}"

# --- CONFIGURACIÓN DE BASE DE DATOS Y USUARIOS ---
if [ ! -d "/var/lib/mysql/$MYSQL_DATABASE" ]; then
    echo -e "${BLUE}[MariaDB] Configurando base de datos...${NC}"
    
    # Comandos de configuración
    mysql -u root <<-EOSQL
        -- Establecer contraseña root
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        
        -- Crear base de datos
        CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
        
        -- Crear usuario y otorgar privilegios
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
        
        -- Aplicar cambios
        FLUSH PRIVILEGES;
EOSQL
    
    echo -e "${GREEN}[MariaDB] Base de datos configurada correctamente${NC}"
else
    echo -e "${GREEN}[MariaDB] Base de datos ya existe, omitiendo configuración${NC}"
fi

# --- DETENER SERVIDOR TEMPORAL Y LANZAR EL FINAL ---

# Matar el proceso mysqld temporal que se inició en background
echo -e "${BLUE}[MariaDB] Deteniendo servidor temporal...${NC}"
kill "$pid"

# Esperar a que el proceso termine antes de lanzar el siguiente
# Esto previene el error 502 al liberar los recursos.
wait "$pid" 2>/dev/null || : 

echo -e "${GREEN}[MariaDB] Iniciando servidor final en foreground...${NC}"

# Iniciar MariaDB en primer plano (PID 1)
exec mysqld --user=mysql --datadir=/var/lib/mysql
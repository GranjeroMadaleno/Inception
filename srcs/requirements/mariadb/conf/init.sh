#!/bin/bash
set -e

echo ">>> 👾 Ejecutando MariaDB Init Script"

# Lectura de secretos existentes (Solo 3 archivos)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
DB_USER_WP_PASS=$(cat /run/secrets/db_password) # Contraseña para usuario WP
ADMIN_PASS=$(cat /run/secrets/db_root_password) # Usamos db_user.txt como la contraseña del Admin

# Lectura de variables de entorno (Nombres)
ADMIN_USER=${MYSQL_USER_ADMIN} # Debe estar definida en .env (e.g., pirateking)
DB_USER_WP=${MYSQL_USER} # Debe estar definida en .env (e.g., wp_user)
DB_NAME=${WORDPRESS_DB_NAME} # Debe estar definida en .env

MARIADB_DATA_DIR="/var/lib/mysql"

if [ ! -d "$MARIADB_DATA_DIR/mysql" ]; then
    echo ">>> 💾 Base de datos NO inicializada. Procediendo a setup..."
    
    mysql_install_db --user=mysql --datadir=$MARIADB_DATA_DIR --skip-test-db
    chown -R mysql:mysql $MARIADB_DATA_DIR

    /usr/bin/mysqld_safe --datadir=$MARIADB_DATA_DIR --user=mysql &
    
    while ! nc -z 127.0.0.1 3306; do
        sleep 1
    done
    echo ">>> ✅ MariaDB temporalmente listo. Creando usuarios..."
    
    mysql -u root -e "
        SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${DB_ROOT_PASSWORD}');
        DELETE FROM mysql.user WHERE User='' OR (User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1'));
        FLUSH PRIVILEGES;
    "
    
    mysql -u root -p"${DB_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;"

    # 1. Usuario WP Normal (db_password.txt)
    mysql -u root -p"${DB_ROOT_PASSWORD}" -e "
        CREATE USER IF NOT EXISTS '${DB_USER_WP}'@'%' IDENTIFIED BY '${DB_USER_WP_PASS}';
        GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER_WP}'@'%' WITH GRANT OPTION;
    "
    
    # 2. Usuario Administrador NO-'admin' (db_user.txt)
    mysql -u root -p"${DB_ROOT_PASSWORD}" -e "
        CREATE USER IF NOT EXISTS '${ADMIN_USER}'@'%' IDENTIFIED BY '${ADMIN_PASS}';
        GRANT ALL PRIVILEGES ON *.* TO '${ADMIN_USER}'@'%' WITH GRANT OPTION;
        FLUSH PRIVILEGES;
    "

    echo ">>> 🛑 Apagando MariaDB temporalmente."
    mysqladmin -u root -p"${DB_ROOT_PASSWORD}" shutdown
fi

if [ -f "$MARIADB_DATA_DIR/init-db.sql" ]; then
    rm -f $MARIADB_DATA_DIR/init-db.sql
fi

echo ">>> 🚀 Iniciando MariaDB en primer plano (PID 1)..."
exec mariadbd \
    --defaults-file=/etc/mysql/my.cnf \
    --user=mysql \
    --datadir=$MARIADB_DATA_DIR \
    --bind-address=0.0.0.0
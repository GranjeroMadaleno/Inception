# Imagen base de Debian 12 Bookworm (penúltima versión estable)
# Stable actual: Debian 13 Trixie | Oldstable: Debian 12 Bookworm
FROM debian:bookworm

# Comandos para instalar MariaDB
RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Copiar configuración personalizada
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copiar script de inicialización y le damos permisos de ejecucion
COPY tools/init-db.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init-db.sh

# Crear directorios necesarios y asignar permisos
RUN mkdir -p /var/run/mysqld /var/log/mysql && \
    chown -R mysql:mysql /var/run/mysqld /var/log/mysql /var/lib/mysql && \
    chmod 755 /var/run/mysqld /var/log/mysql

# Puerto estandar de MySQL/mariaDB
EXPOSE 3306

# Ejecutar script de inicialización
ENTRYPOINT ["/usr/local/bin/init-db.sh"]


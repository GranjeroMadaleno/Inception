# Azkenaurreko irudia Debian 12 "Bookworn" da. Berriena Debian 13 Trixie 

FROM debian:bookworm

# MariaDB instalatzeko komandoak

RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Konfigurazio pertsonalizatua kopiatu

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Hasieratze skripta kopiatu eta baimenak ezarri

COPY tools/init-db.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init-db.sh

# Direktorioak sortu eta baimenak ezarri

RUN mkdir -p /var/run/mysqld /var/log/mysql && \
    chown -R mysql:mysql /var/run/mysqld /var/log/mysql /var/lib/mysql && \
    chmod 755 /var/run/mysqld /var/log/mysql

# MySQL/mariaDB portua

EXPOSE 3306

# Hasieratze skripta exekutatu

ENTRYPOINT ["/usr/local/bin/init-db.sh"]


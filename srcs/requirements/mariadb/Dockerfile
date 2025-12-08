FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive

# 1. INSTALAR MARIADB (Crea el usuario 'mysql')
RUN apt-get update \
    && apt-get install -y mariadb-server netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# 2. CREAR Y ASIGNAR PERMISOS para /run/mysqld
RUN mkdir -p /run/mysqld \
    && chown -R mysql:mysql /run/mysqld

RUN mkdir -p /var/log/mysql \
    && chown -R mysql:mysql /var/log/mysql

COPY ./conf/my.cnf /etc/mysql/my.cnf
# Copiamos init.sh (el archivo que existe) y lo renombramos a start.sh dentro del contenedor.
COPY ./conf/init.sh /usr/local/bin/start.sh
# Copiamos create.sh, ya que también existe en tu carpeta /conf/
COPY ./conf/create.sh /usr/local/bin/create.sh 
RUN chmod +x /usr/local/bin/start.sh /usr/local/bin/create.sh

RUN chown -R mysql:mysql /var/lib/mysql

VOLUME /var/lib/mysql

USER mysql

ENTRYPOINT ["/usr/local/bin/start.sh"]
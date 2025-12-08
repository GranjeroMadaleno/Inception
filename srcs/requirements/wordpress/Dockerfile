FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive

# 1. Instalar PHP-FPM, extensiones, wget y netcat (para esperar a la DB)
RUN apt-get update \
    && apt-get install -y php-fpm php-mysql php-cli wget netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# 2. Descargar e instalar WP-CLI
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# 3. Descargar, desempaquetar y configurar WordPress
WORKDIR /var/www/html
RUN wget https://wordpress.org/latest.tar.gz \
    && tar -xzf latest.tar.gz --strip-components=1 \
    && rm latest.tar.gz

# 4. Copiar la configuración de PHP-FPM (la pool www.conf que configuraste)
COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# 5. Copiar script de inicio
COPY ./conf/init-wordpress.sh /usr/local/bin/init-wordpress.sh
RUN chmod +x /usr/local/bin/init-wordpress.sh

EXPOSE 9000

# 6. El ENTRYPOINT llama al script que ejecuta PHP-FPM como PID 1
ENTRYPOINT ["/usr/local/bin/init-wordpress.sh"]
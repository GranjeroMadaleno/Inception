# Imagen base de Debian 12 Bookworm
FROM debian:bookworm

# Configuración para evitar que apt-get espere interacción, previniendo cuelgues.
ARG DEBIAN_FRONTEND=noninteractive

# Instalar PHP-FPM y extensiones necesarias para WordPress
RUN apt-get update && apt-get install -y \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-mysqli \
    php8.2-curl \
    php8.2-gd \
    php8.2-intl \
    php8.2-mbstring \
    php8.2-soap \
    php8.2-xml \
    php8.2-xmlrpc \
    php8.2-zip \
    curl \
    wget \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Descargar WP-CLI (herramienta para gestionar WordPress desde línea de comandos)
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Copiar configuración de PHP-FPM (www.conf)
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# Copiar script de inicialización
# NOMBRE DE SCRIPT CORREGIDO: setup-wp.sh
COPY tools/setup-wp.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup-wp.sh

# Crear directorios necesarios y asignar permisos al usuario 'www-data' (usuario de PHP-FPM)
RUN mkdir -p /var/www/html && \
    chown -R www-data:www-data /var/www/html

# Crear directorio para el socket de PHP-FPM
RUN mkdir -p /run/php && \
    chown -R www-data:www-data /run/php

# Exponer puerto 9000 (PHP-FPM)
EXPOSE 9000

# Directorio de trabajo
WORKDIR /var/www/html

# Ejecutar script de inicialización
ENTRYPOINT ["/usr/local/bin/setup-wp.sh"]
# Irudia: Debian 12 "Bookworn"

FROM debian:bookworm

# apt-get azkarrago joateko konfigurazioa
ARG DEBIAN_FRONTEND=noninteractive

# PHP-FPM instalatu eta WordPress-erako behar diren luzapenak
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

# WP-CLI deskargatu (WordPress komandoekin kudeatzeko tresna)
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# PHP-FPM konfigurazioa kopiatu (www.conf)
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# Abiarazpen skripta kopiatu
COPY tools/setup-wp.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup-wp.sh

# Beharrezko direktorioak sortu eta erabiltzaileari baimenak esleitu 'www-data'

RUN mkdir -p /var/www/html && \
    chown -R www-data:www-data /var/www/html

# PHP-FPM socket-erako direktorioa sortu
RUN mkdir -p /run/php && \
    chown -R www-data:www-data /run/php

# 9000 portua ireki edo baimendu (PHP-FPM)
EXPOSE 9000

# Proiektuaren fitxategia
WORKDIR /var/www/html

# Hasieratze skripta exekutatu
ENTRYPOINT ["/usr/local/bin/setup-wp.sh"]
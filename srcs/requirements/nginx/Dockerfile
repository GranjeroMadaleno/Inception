# Irudia: Debian 12 "Bookworn"

FROM debian:bookworm

# NGINX eta OpenSSL instalatu

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# NGINX konfigurazioa kopiatu

COPY conf/nginx.conf /etc/nginx/nginx.conf

# Ziurtagiriak sortu eta skripta kopiatu

COPY tools/setup-ssl.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup-ssl.sh

# Hemen sortzen dira SSL ziurtagiriak

RUN mkdir -p /etc/nginx/ssl

# log fitxategia sortu

RUN mkdir -p /var/log/nginx

# 443 portua baimendu (HTTPS)

EXPOSE 443

# Hasieratze skripta exekutatu

ENTRYPOINT ["/usr/local/bin/setup-ssl.sh"]


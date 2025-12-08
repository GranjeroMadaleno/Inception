# Imagen base de Debian 12 Bookworm (penúltima versión estable)
FROM debian:bookworm

# Instalar NGINX y OpenSSL
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Copiar configuración de NGINX
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Copiar script de inicialización (genera certificados SSL)
COPY tools/setup-ssl.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup-ssl.sh

# Crear directorio para certificados SSL
RUN mkdir -p /etc/nginx/ssl

# Crear directorio para logs
RUN mkdir -p /var/log/nginx

# Exponer puerto 443 (HTTPS)
EXPOSE 443

# Ejecutar script de inicialización
ENTRYPOINT ["/usr/local/bin/setup-ssl.sh"]


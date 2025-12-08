FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y nginx openssl && apt-get clean

# 1. ELIMINAR CONFIGURACIONES PREDETERMINADAS
RUN rm -f /etc/nginx/sites-enabled/default

# 2. COPIAR LA CONFIGURACIÓN DEL USUARIO AL LUGAR PRINCIPAL
COPY ./conf/nginx.conf /etc/nginx/nginx.conf

EXPOSE 443

CMD ["nginx", "-c", "/etc/nginx/nginx.conf", "-g", "daemon off;"]
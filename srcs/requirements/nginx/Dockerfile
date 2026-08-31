FROM debian:bullseye

RUN apt-get update && apt-get install -y nginx openssl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ARG DOMAIN_NAME

RUN mkdir -p /etc/nginx/ssl
RUN openssl req -x509 -nodes -days 365 -out /etc/nginx/ssl/iception.crt -keyout /etc/nginx/ssl/iception.key \
    -subj "/C=MA/ST=Marrakesh/L=Benguerir/O=1337/OU=Student/CN=${DOMAIN_NAME}"

COPY /conf/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
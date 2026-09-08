FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    wget \
    php8.2-cli \
    php8.2-mysql \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html
RUN wget "http://www.adminer.org/latest.php" -O /var/www/html/index.php

WORKDIR /var/www/html

CMD ["php8.2", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]
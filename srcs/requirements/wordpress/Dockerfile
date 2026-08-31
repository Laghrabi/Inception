FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    php7.4-fpm \
    php7.4-mysql \
    curl \
    wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

COPY tools/setup.sh /usr/local/bin/setup.sh

RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 9000

CMD ["/usr/local/bin/setup.sh"]
FROM debian:bookworm

RUN apt update -y && apt upgrade -y && \
    apt install -y php8.2 php-fpm php-mysql mariadb-client curl wget && \
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/run-script.sh /usr/local/bin

RUN chmod +x /usr/local/bin/run-script.sh

RUN mkdir -p /var/www/html /run/php && \
    chown -R www-data:www-data /var/www/html /run/php

ENTRYPOINT ["/usr/local/bin/run-script.sh"]

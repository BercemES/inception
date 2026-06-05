FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    php8.2-fpm \
    php8.2-mysql \
    mariadb-client \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

RUN mkdir -p /run/php /var/www/wordpress

RUN curl -o /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz && \
    tar -xvf /tmp/wordpress.tar.gz -C /var/www/wordpress --strip-components=1 && \
    rm /tmp/wordpress.tar.gz


RUN chown -R www-data:www-data /var/www/wordpress

WORKDIR /var/www/wordpress

RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

COPY ./tools/create_wp.sh /usr/local/bin/wp_setup.sh
RUN chmod +x /usr/local/bin/wp_setup.sh


EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wp_setup.sh"]

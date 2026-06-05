FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl

COPY ./conf/nginx.conf /etc/nginx/nginx.conf

COPY ./tools/nginx.sh /usr/local/bin/nginx.sh
RUN chmod +x /usr/local/bin/nginx.sh

RUN mkdir -p /var/www/wordpress

EXPOSE 443

ENTRYPOINT ["sh", "/usr/local/bin/nginx.sh"]
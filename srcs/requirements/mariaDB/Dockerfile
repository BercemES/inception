FROM debian:bullseye

RUN apt-get update && apt-get install -y mariadb-server

COPY ./conf/mariadb.conf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/create_db.sh /usr/local/bin/create_db.sh

RUN chmod +x /usr/local/bin/create_db.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/create_db.sh"]
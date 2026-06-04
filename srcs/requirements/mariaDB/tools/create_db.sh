#!/bin/bash

set -e

if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

mysqld_safe --user=mysql --datadir=/var/lib/mysql & 

until mysqladmin ping --silent; do
	sleep 3
done

mysql -e "CREATE DATABASE IF NOT EXISTS \`${DB_DATABASE}\`;"
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';"
mysql -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';"
mysql -e "GRANT ALL PRIVILEGES ON \`${DB_DATABASE}\`.* TO '${DB_USER}'@'%';"
mysql -e "FLUSH PRIVILEGES;"

mysqladmin shutdown

echo "starting MariaDB server..."

exec mysqld_safe --user=mysql --datadir=/var/lib/mysql
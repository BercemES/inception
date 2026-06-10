#!/bin/bash

set -e

DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
DB_PASSWORD=$(cat /run/secrets/db_password)

if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

mysqld_safe --user=mysql --datadir=/var/lib/mysql & 

until mysqladmin ping --silent; do
	sleep 3
done

mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';"

mysql -u root -p"CREATE DATABASE IF NOT EXISTS \`${DB_DATABASE}\`;"
mysql -u root -p"ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';"
mysql -u root -p"CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';"
mysql -u root -p"GRANT ALL PRIVILEGES ON \`${DB_DATABASE}\`.* TO '${DB_USER}'@'%';"
mysql -u root -p"FLUSH PRIVILEGES;"

mysqladmin -u root -p"${DB_ROOT_PASSWORD}" shutdown

echo "starting MariaDB server..."

exec mysqld_safe --user=mysql --datadir=/var/lib/mysql
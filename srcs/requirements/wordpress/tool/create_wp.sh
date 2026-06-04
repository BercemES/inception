#!/bin/bash

echo "Waiting Database to ready..."
until mariadb-admin ping -h mariadb -u $MYSQL_USER --password=$MYSQL_PASSWORD --silent; do
    sleep 2
done
echo "Database ready!"

if [ ! -f "wp-config.php" ]; then
    echo "Creating wp-config.php..."
    wp config create --dbname="$DB_DATABASE" \
                     --dbuser="$DB_USER" \
                     --dbpass="$DB_PASSWORD" \
                     --dbhost="$DB_HOST" \
                     --allow-root --skip-check
    
    wp core install --url="$DOMAIN_NAME" \
                    --title="Inception Project" \
                    --admin_user="$WP_ADMIN_USER" \
                    --admin_password="$WP_ADMIN_PASSWORD" \
                    --admin_email="$WP_ADMIN_EMAIL" \
                    --allow-root
    
    wp user create "$WP_USER_USER" "$WP_USER_EMAIL" \
                    --role=author \
                    --user_pass="$WP_USER_PASSWORD" \
                    --allow-root
fi

chown -R www-data:www-data /var/www/html

exec php-fpm8.2 -F
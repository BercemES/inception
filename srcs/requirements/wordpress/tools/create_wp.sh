#!/bin/bash

set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ROOT_PASSWORD=$(cat /run/secrets/wp_root_password)

echo "Waiting Database to ready..."
until mariadb-admin ping -h mariadb -u $DB_USER --password=$DB_PASSWORD --silent; do
    sleep 2
done
echo "Database ready!"

if [ ! -f "wp-config.php" ]; then
    echo "Creating wp-config.php..."
    wp config create --dbname="$WORDPRESS_DB_NAME" \
                     --dbuser="$DB_USER" \
                     --dbpass="$DB_PASSWORD" \
                     --dbhost="$WORDPRESS_DB_HOST" \
                     --allow-root --skip-check
    
    wp core install --url="$DOMAIN_NAME" \
                    --title="Inception Project" \
                    --admin_user="$WP_ROOT_USER" \
                    --admin_password="$WP_ROOT_PASSWORD" \
                    --admin_email="$WP_ROOT_EMAIL" \
                    --allow-root
    
    wp user create "$WP_USER_USER" "$WP_USER_EMAIL" \
                    --role=author \
                    --user_pass="$WP_USER_PASSWORD" \
                    --allow-root
fi

chown -R www-data:www-data /var/www/wordpress

exec php-fpm8.2 -F
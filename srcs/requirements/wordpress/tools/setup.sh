#!/bin/bash

WP_PATH="/var/www/wordpress"
WP_CLI_URL="https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar"

echo "Waiting for MariaDB to boot..."
until bash -c "echo > /dev/tcp/mariadb/3306" 2> /dev/null; do
    sleep 2
done
echo "MariaDB is active! Proceeding with WordPress setup..."

mkdir -p $WP_PATH
cd $WP_PATH

if [ ! -f "/usr/local/bin/wp" ]; then
    curl -O $WP_CLI_URL
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo "Downloading WordPress core files..."
    wp core download --allow-root

    echo "Connecting WordPress to MariaDB..."
    wp config create \
        --dbname=$MYSQL_DATABASE \
        --dbuser=$MYSQL_USER \
        --dbpass=$MYSQL_PASSWORD \
        --dbhost=mariadb \
        --allow-root

    echo "Installing WordPress site..."
    wp core install \
        --url=$DOMAIN_NAME \
        --title="Inception" \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PASSWORD \
        --admin_email=$WP_ADMIN_EMAIL \
        --allow-root
    
    echo "Creating standard user..."
    wp user create \
        $WP_USER \
        $WP_EMAIL \
        --role=author \
        --user_pass=$WP_PASSWORD \
        --allow-root
fi

mkdir -p /run/php

echo "Starting PHP-FPM 7.4..."
exec php-fpm7.4 -F
#!/bin/bash

sleep 10

cd /var/www/html

if [ ! -f wp-config.php ]; then

    wp core download --allow-root

    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --allow-root

    wp core install \
        --url="${DOMAIN_NAME}" \
        --title="${SITE_TITLE}" \
        --admin_user="${ADMIN_USER}" \
        --admin_password="${ADMIN_PASS}" \
        --admin_email="${ADMIN_MAIL}" \
        --allow-root

    wp user create \
        "${WP_USER}" "${WP_MAIL}" \
        --user_pass="${WP_USER_PASS}" \
        --role=author \
        --allow-root

fi

exec php-fpm8.2 -F
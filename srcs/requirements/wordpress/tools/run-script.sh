cd /var/www/html

if [! -f wp-config.php]; then
    wp core download
    wp config create --dbname=${MYSQL_DATABASE} --dbuser=${MYSQL_USER} --dbpass=${MYSQL_PASSWORD} --dbhost=mariadb:3306
    wp core install --url=${DOMAIN_NAME} --title=${SITE_TITLE} --admin_user=${ADMIN_USER} --admin_password=${ADMIN_PASS} --admin_email=${ADMIN_MAIL}
    wp user create ${WP_USER} ${ADMIN_MAIL} --user_pass=${WP_USER_PASS} --role=author
fi

exec php-fpm8.2 -F
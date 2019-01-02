FROM thecodingmachine/php:7.2-v2-apache-node8

ENV APACHE_DOCUMENT_ROOT=/public \
    TEMPLATE_PHP_INI=production \
    PHP_EXTENSIONS="amqp bcmath calendar exif gd gettext \
gmp gnupg igbinary imagick imap intl ldap mcrypt memcached \
mongodb pcntl pdo_dblib pdo_pgsql pgsql sockets yaml"

# This just didn't work :(
# It seems that we cann't set ENV variables dynamically
# ONBUILD ENV PHP_EXTENSIONS=$(composer check-platform-reqs | grep ^ext- | grep missing | awk '{print $1}' | cut -b 5- | paste -sd " " -)

USER root

ONBUILD COPY . /var/www/html

ONBUILD RUN if [ -f /var/www/html/package-lock.json ]; then \
    echo 'Running npm ci...' && npm ci && npm run prod; \
  else \
    echo 'Running npm install...' && npm install && npm run prod; \
fi

ONBUILD RUN mkdir -p bootstrap/cache \
  && sudo chgrp -R www-data storage bootstrap/cache \
  && sudo chmod -R ug+rwx storage bootstrap/cache \
  && composer install \
    --no-dev \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader \
    --ansi

ENV APACHE_RUN_USER=www-data \
    APACHE_RUN_GROUP=www-data \
    COMPOSER_ALLOW_SUPERUSER=1
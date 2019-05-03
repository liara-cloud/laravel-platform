FROM thecodingmachine/php:7.2-v2-apache-node10

ENV ROOT=/var/www/html

ENV APACHE_DOCUMENT_ROOT=/public \
    TEMPLATE_PHP_INI=production \
    LOG_CHANNEL=errorlog \
    PHP_EXTENSIONS="amqp bcmath calendar exif gd gettext \
gmp gnupg igbinary imagick imap intl ldap mcrypt memcached \
mongodb pcntl pdo_dblib pdo_pgsql pgsql sockets yaml \
apcu mysqli opcache pdo pdo_mysql redis zip soap"

USER root

RUN composer global require hirak/prestissimo && \
    composer global require bamarni/symfony-console-autocomplete && \
    rm -rf $HOME\.composer

ONBUILD COPY . $ROOT

ONBUILD RUN mkdir -p bootstrap/cache \
  && sudo chgrp -R www-data storage bootstrap/cache \
  && sudo chmod -R ug+rwx storage bootstrap/cache \
  && composer install \
    --no-dev \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader \
    --ansi

ONBUILD RUN if [ $__LARAVEL_BUILDASSETS == 'true' ] && [ -f $ROOT/package-lock.json ]; then \
    echo 'Running npm ci...' && npm ci && npm run prod; \
  else \
    echo 'Running npm install...' && npm install && npm run prod; \
fi

ENV APACHE_RUN_USER=www-data \
    APACHE_RUN_GROUP=www-data \
    COMPOSER_ALLOW_SUPERUSER=1
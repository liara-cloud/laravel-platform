FROM php:7.2-fpm

RUN apt-get update && \
  apt-get install -y --no-install-recommends vim nano git curl wget unzip nginx procps

ENV COMPOSER_ALLOW_SUPERUSER 1

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer &&\
    chmod +x /usr/local/bin/composer

WORKDIR /var/www/html

COPY utils/utils.php /usr/local/bin/utils.php
COPY utils/generate_conf.php /usr/local/bin/generate_conf.php
COPY utils/install_selected_extensions.php /usr/local/bin/install_selected_extensions.php

COPY ./exts/core /usr/local/lib/thecodingmachine-php/extensions/current

ENV PHP_EXTENSIONS="amqp bcmath calendar exif gd gettext \
gmp gnupg igbinary imagick imap intl ldap mcrypt memcached \
mongodb pcntl pdo_dblib pdo_pgsql pgsql sockets yaml \
apcu mysqli opcache pdo pdo_mysql redis zip soap"
RUN PHP_EXTENSIONS="$PHP_EXTENSIONS" php /usr/local/bin/install_selected_extensions.php

RUN composer global require hirak/prestissimo && \
    composer global require bamarni/symfony-console-autocomplete && \
    rm -rf $HOME\.composer

ONBUILD COPY . /var/www/html

ONBUILD RUN mkdir -p bootstrap/cache \
  && chgrp -R www-data storage bootstrap/cache \
  && chmod -R ug+rwx storage bootstrap/cache \
  && composer install \
    --no-dev \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader \
    --ansi

COPY ./run.sh /run.sh
COPY nginx.conf /etc/nginx/nginx.conf
COPY default_liara_nginx.conf /etc/nginx/conf.d/liara_nginx.conf

CMD /run.sh

RUN chmod +x /run.sh && \
  # Install Node 10
  apt-get update && \
    apt-get install -y --no-install-recommends gnupg && \
    curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    apt-get update && \
    apt-get install -y --no-install-recommends nodejs && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends yarn

ENTRYPOINT
FROM php:7.2-apache

RUN apt-get update && \
  apt-get install -y --no-install-recommends vim nano git curl wget unzip cron supervisor

ENV COMPOSER_ALLOW_SUPERUSER=1 \
    ROOT=/var/www/html

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer &&\
    chmod +x /usr/local/bin/composer

WORKDIR $ROOT

COPY utils/utils.php /usr/local/bin/utils.php
COPY utils/generate_conf.php /usr/local/bin/generate_conf.php
COPY utils/install_selected_extensions.php /usr/local/bin/install_selected_extensions.php

COPY ./exts/core /usr/local/lib/thecodingmachine-php/extensions/current

ENV PHP_EXTENSIONS="bcmath bz2 calendar exif \
gd gettext gmp igbinary imagick intl \
pcntl pdo_pgsql pgsql redis \
shmop soap sysvmsg \
sysvsem sysvshm wddx xsl opcache zip"
RUN PHP_EXTENSIONS="$PHP_EXTENSIONS" php /usr/local/bin/install_selected_extensions.php

RUN composer global require hirak/prestissimo && \
    rm -rf $HOME\.composer

RUN php /usr/local/bin/generate_conf.php | tee /usr/local/etc/php/conf.d/generated_conf.ini > /dev/null

COPY supervisord.conf /etc/supervisord.conf

ONBUILD COPY . $ROOT

ONBUILD ARG COMPOSER_INSTALL=true
ONBUILD RUN mkdir -p bootstrap/cache \
  && chgrp -R www-data storage bootstrap/cache \
  && chmod -R ug+rwx storage bootstrap/cache; \
  if [ "COMPOSER_INSTALL" = "true"]; then composer install \
    --no-dev \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader \
    --ansi \
    --no-scripts; \
fi

ENTRYPOINT cron \
  && chgrp -R www-data storage public
  && chmod -R ug+rwx storage public
  && docker-php-entrypoint

CMD ["apache2-foreground"]
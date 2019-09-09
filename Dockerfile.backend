FROM php:7.2-apache-stretch

RUN apt-get update && \
  apt-get install -y --no-install-recommends vim nano git curl wget unzip cron supervisor python3

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
amqp gnupg imap mcrypt memcached \
mongodb sockets yaml \
gd gettext gmp igbinary imagick intl \
pcntl pdo_pgsql pgsql redis \
shmop soap sysvmsg \
apcu mysqli pdo_mysql \
sysvsem sysvshm wddx xsl opcache zip"
RUN PHP_EXTENSIONS="$PHP_EXTENSIONS" php /usr/local/bin/install_selected_extensions.php

RUN composer global require hirak/prestissimo && \
    rm -rf $HOME\.composer

RUN php /usr/local/bin/generate_conf.php | tee /usr/local/etc/php/conf.d/generated_conf.ini > /dev/null

RUN sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf \
  && sed -ri -e 's!/var/www/!/var/www/html/public!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf \
  && a2enmod rewrite \
  && a2enmod alias \
  && a2enmod authz_host \
  && a2enmod deflate \
  && a2enmod dir \
  && a2enmod expires \
  && a2enmod headers \
  && a2enmod mime \
  && a2enmod autoindex \
  && a2enmod negotiation \
  && a2enmod setenvif \
  && echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf \
  && a2enconf servername

ENV PYTHONIOENCODING=utf-8 \
    LANG=C.UTF-8

COPY supervisord.conf /etc/supervisord.conf

ONBUILD COPY . $ROOT
ONBUILD COPY --from=0 /app/public $ROOT/public

ONBUILD RUN mkdir -p bootstrap/cache \
  && chgrp -R www-data storage bootstrap/cache \
  && chmod -R ug+rwx storage bootstrap/cache \
  && composer install \
    --no-dev \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader \
    --ansi \
    --no-scripts

COPY load_profile.py /usr/local/bin/load_profile.py
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY config-laravel.sh /usr/local/bin/config-laravel.sh

ONBUILD ARG __CRON
ONBUILD ARG __VOLUME_PATH
ONBUILD RUN echo 'Reading config arguments...'
ONBUILD ARG __LARAVEL_CONFIGCACHE=false
ONBUILD ARG __LARAVEL_ROUTECACHE=false
ONBUILD ARG __LARAVEL_POSTBUILDCOMMANDS
ONBUILD ENV __CRON=${__CRON} \
  __VOLUME_PATH=${__VOLUME_PATH} \
  __LARAVEL_CONFIGCACHE=${__LARAVEL_CONFIGCACHE} \
  __LARAVEL_ROUTECACHE=${__LARAVEL_ROUTECACHE} \
  __LARAVEL_POSTBUILDCOMMANDS=${__LARAVEL_POSTBUILDCOMMANDS}
ONBUILD RUN rm -rf $ROOT/bootstrap/cache/* \
  && /usr/local/bin/config-laravel.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["apache2-foreground"]

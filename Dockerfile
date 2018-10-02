FROM composer:1.7 as composer

FROM php:7.2-apache

COPY --from=composer /usr/bin/composer /usr/bin/composer

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    git \
    curl \
    unzip \
    libmemcached-dev \
    libz-dev \
    libpq-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libssl-dev \
    libmcrypt-dev \
    gnupg \
  && curl -sL https://deb.nodesource.com/setup_8.x | bash - \
  && apt-get install -y nodejs \
  && rm -rf /var/lib/apt/lists/*

# Install the PHP mcrypt extention
RUN pecl install mcrypt-1.0.1 && \
  docker-php-ext-enable mcrypt \
  # Install the PHP pdo_mysql extention
  && docker-php-ext-install pdo_mysql \
  # Install the PHP pdo_pgsql extention
  && docker-php-ext-install pdo_pgsql \
  # Install the PHP gd library
  && docker-php-ext-configure gd \
    --with-jpeg-dir=/usr/lib \
    --with-freetype-dir=/usr/include/freetype2 && \
    docker-php-ext-install gd

# always run apt update when start and after add new source list, then clean up at end.
RUN apt-get update -yqq && \
    pecl channel-update pecl.php.net

###########################################################################
# ZipArchive:
###########################################################################

ARG INSTALL_ZIP_ARCHIVE=true

RUN if [ ${INSTALL_ZIP_ARCHIVE} = true ]; then \
    # Install the zip extension
    docker-php-ext-install zip \
;fi


# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog


# Put apache and php.ini configs for Laravel
COPY ./php.ini /usr/local/etc/php/php.ini
COPY apache2-laravel.conf /etc/apache2/sites-available/laravel.conf
RUN a2dissite 000-default.conf && a2ensite laravel.conf && a2enmod rewrite

# Change uid and gid of apache to docker user uid/gid
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data

WORKDIR /var/www/html

ENV COMPOSER_ALLOW_SUPERUSER=1

ONBUILD COPY . .

# Install composer dependencies
ONBUILD RUN chgrp -R www-data storage bootstrap/cache \
 && chmod -R ug+rwx storage bootstrap/cache \
 && composer install --no-dev --prefer-dist --optimize-autoloader

# Install NPM dependencies and build assets
ONBUILD RUN npm install && npm run production

HEALTHCHECK --start-period=1m --interval=5m --timeout=3s \
  CMD curl -s http://localhost > /dev/null || exit 1

ENV APP_LOG=errorlog

EXPOSE 80
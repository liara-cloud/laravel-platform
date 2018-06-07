FROM composer:1.6 as composer

FROM php:7.1-fpm

COPY --from=composer /usr/bin/composer /usr/bin/composer

# Install "nginx", "git", "curl", "libmemcached-dev", "libpq-dev", "libjpeg-dev",
#         "libpng12-dev", "libfreetype6-dev", "libssl-dev", "libmcrypt-dev",
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    nginx \
    git \
    curl \
    supervisor \
    libmemcached-dev \
    libz-dev \
    libpq-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libssl-dev \
    libmcrypt-dev \
  && rm -rf /var/lib/apt/lists/*

# Install the PHP mcrypt extention
RUN docker-php-ext-install mcrypt \
  # Install the PHP pdo_mysql extention
  && docker-php-ext-install pdo_mysql \
  # Install the PHP pdo_pgsql extention
  && docker-php-ext-install pdo_pgsql \
  # Install the PHP gd library
  && docker-php-ext-configure gd \
    --enable-gd-native-ttf \
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

#
#--------------------------------------------------------------------------
# Final Touch
#--------------------------------------------------------------------------
#

COPY ./laravel.ini /usr/local/etc/php/conf.d
COPY ./xlaravel.pool.conf /usr/local/etc/php-fpm.d/

USER root

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

RUN usermod -u 1000 www-data

WORKDIR /var/www

ONBUILD COPY . /var/www

ONBUILD RUN composer install && \
 chgrp -R www-data storage bootstrap/cache && \
 chmod -R ug+rwx storage bootstrap/cache

COPY nginx.conf /etc/nginx/
COPY sites/* /etc/nginx/sites-available/

COPY ./supervisord.conf /etc/supervisord.conf
CMD supervisord -n -c /etc/supervisord.conf

EXPOSE 80
#!/usr/bin/env bash

set -e
export EXTENSION=gd
export DEV_DEPENDENCIES="libjpeg62-turbo-dev libpng-dev libxpm-dev libfreetype6-dev libwebp-dev"
export DEPENDENCIES="libjpeg62-turbo libpng16-16 zlib1g libxpm4 libfreetype6 libwebp6"

if [ $PHP_VERSION = "7.4" ]; then
  export CONFIGURE_OPTIONS="--with-freetype --with-jpeg --with-xpm --with-webp"
else
  export CONFIGURE_OPTIONS="--with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-xpm-dir=/usr/include/ --with-webp-dir=/usr/include/"
fi

../docker-install.sh
# https://github.com/docker-library/php/issues/931

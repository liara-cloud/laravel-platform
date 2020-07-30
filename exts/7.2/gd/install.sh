#!/usr/bin/env bash

set -e
export EXTENSION=gd
export DEV_DEPENDENCIES="libjpeg62-turbo-dev libpng-dev libxpm-dev libfreetype6-dev libwebp-dev"
export DEPENDENCIES="libjpeg62-turbo libpng16-16 zlib1g libxpm4 libfreetype6 libwebp6"
export CONFIGURE_OPTIONS="--with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-xpm-dir=/usr/include/ --with-webp-dir=/usr/include/"

../docker-install.sh

#!/usr/bin/env bash

set -e
export EXTENSION=zip

if [ $PHP_VERSION = "7.2" ]; then
  export DEV_DEPENDENCIES="zlib1g-dev"
  export DEPENDENCIES="zlib1g"
else
  export DEV_DEPENDENCIES="libzip-dev"
  export DEPENDENCIES="libzip4"
fi

../docker-install.sh

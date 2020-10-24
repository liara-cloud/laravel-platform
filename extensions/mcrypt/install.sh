#!/usr/bin/env bash

set -e
# Comments: MCrypt is deprecated and usage is generally discouraged. Provided here for legacy apps only.

export PECL_EXTENSION=mcrypt-1.0.1
export PHP_EXT_NAME=mcrypt # name of the extension (to put in PHP_EXTENSIONS variable)
export DEV_DEPENDENCIES="libmcrypt-dev"
export DEPENDENCIES="libmcrypt4"

../docker-install.sh

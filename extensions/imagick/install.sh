#!/usr/bin/env bash

set -e

apt-get install -y libmagickwand-dev --no-install-recommends
printf "\n" | pecl install imagick

# https://webapplicationconsultant.com/docker/how-to-install-imagick-in-php-docker/

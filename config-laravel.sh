#!/bin/bash

composer dump-autoload --ansi

if grep -q '"post-install-cmd"' composer.json; then
  composer run-script --no-dev post-install-cmd --ansi
fi

php artisan view:clear
php artisan cache:clear

set -e

if [ -f $ROOT/supervisor.conf ]; then
  echo 'Applying supervisor.conf...'
  mkdir -p /etc/supervisord.d
  mv $ROOT/supervisor.conf /etc/supervisord.d
fi

if [ -f $ROOT/liara_php.ini ]; then
  echo 'Applying liara_php.ini...'
  mkdir -p /usr/local/etc/php/conf.d
  mv $ROOT/liara_php.ini /usr/local/etc/php/conf.d
fi

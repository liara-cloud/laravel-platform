#!/bin/bash

set -e

php artisan view:clear
php artisan cache:clear

if [ -f $ROOT/supervisor.conf ]; then
  echo 'Applying supervisor.conf...'
  mkdir -p /etc/supervisord.d
  mv $ROOT/supervisor.conf /etc/supervisord.d
fi

if [ -f $ROOT/php.ini ]; then
  echo 'Applying liara_php.ini...'
  mkdir -p /usr/local/etc/php/conf.d
  mv $ROOT/liara_php.ini /usr/local/etc/php/conf.d
fi
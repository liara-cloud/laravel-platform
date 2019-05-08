#!/bin/bash

set -e

php artisan view:clear
php artisan cache:clear

if [ "$__LARAVEL_CONFIGCACHE" = "true" ]; then
  php artisan config:cache
fi

if [ "$__LARAVEL_ROUTECACHE" = "true" ]; then
  php artisan route:cache
fi

if [ -f $ROOT/supervisor.conf ]; then
  echo 'Applying supervisor.conf...'
  mkdir -p /etc/supervisord.d
  mv $ROOT/supervisor.conf /etc/supervisord.d
fi
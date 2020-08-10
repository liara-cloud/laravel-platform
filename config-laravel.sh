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

chgrp -R www-data storage public
chmod -R ug+rwx storage public

set +e

if [ "$__LARAVEL_CONFIGCACHE" = "true" ]; then
  php artisan config:cache
fi

if [ "$__LARAVEL_ROUTECACHE" = "true" ]; then
  php artisan route:cache
fi

# Prepare for read-only filesystem
set -e
mkdir /tmp/.laravel-framework
mkdir /var/www/.laravel-framework
mv /var/www/html/storage/framework/* /var/www/.laravel-framework
rm -rf /var/www/html/storage/framework
ln -s /tmp/.laravel-framework /var/www/html/storage/framework

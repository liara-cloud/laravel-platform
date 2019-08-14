#!/bin/bash

set -e

chgrp -R www-data storage public
chmod -R ug+rwx storage public

python3 /usr/local/bin/load_profile.py
chmod 0644 /etc/cron.d/liara_cron
crontab /etc/cron.d/liara_cron

if [ ! -z "$__VOLUME_PATH" ]; then
  echo 'Configuring volume...'
  chgrp -R www-data $__VOLUME_PATH
  chmod -R ug+rwx $__VOLUME_PATH
fi

if [ "$__LARAVEL_CONFIGCACHE" = "true" ]; then
  php artisan config:cache
fi

if [ "$__LARAVEL_ROUTECACHE" = "true" ]; then
  php artisan route:cache
fi

php artisan package:discover --ansi

if [ ! -z "$__CRON" ]; then cron; fi

if [ -f /etc/supervisord.d/supervisor.conf ]; then
  echo 'Starting supervisor...'
  supervisord -c /etc/supervisord.conf
fi

exec "docker-php-entrypoint" "$@";

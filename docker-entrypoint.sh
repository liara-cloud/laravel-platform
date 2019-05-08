#!/bin/bash

set -e

chgrp -R www-data storage public
chmod -R ug+rwx storage public

if [ ! -z "$__VOLUME_PATH" ]; then
  echo 'Configuring volume...'
  chgrp -R www-data $__VOLUME_PATH
  chmod -R ug+rwx $__VOLUME_PATH
fi

php artisan package:discover --ansi

if [ ! -z "$__CRON" ]; then cron; fi

if [ -f /etc/supervisord.d/supervisor.conf ]; then
  echo 'Starting supervisor...'
  supervisord -c /etc/supervisord.conf
fi

exec "docker-php-entrypoint" "$@";
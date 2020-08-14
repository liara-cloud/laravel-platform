#!/bin/bash

# Is storage writable? In other words, is a disk mounted to the storage directory or its parents?
df | grep -q '/var/www/html/storage$' || df | grep -q '/var/www/html$' || df | grep -q '/var/www$' || df | grep -q '/var$'
if [[ $? == '0' ]]; then
  echo '---------------- disk exists.'
  # Is symlink?
  if [[ -L "/var/www/html/storage/framework" ]]; then
    echo '------------------- Removing symlink'
    rm /var/www/html/storage/framework
    mkdir /var/www/html/storage/framework
    cp -rp /var/www/.laravel-framework/* /var/www/html/storage/framework
  fi
else
  mkdir -p /tmp/.laravel-framework
  chown www-data:www-data /tmp/.laravel-framework
  if [[ -z "$(ls -A /tmp/.laravel-framework)" ]]; then
    echo '----------------- copying .laravel-framework'
    cp -rp /var/www/.laravel-framework/* /tmp/.laravel-framework
  fi
fi

set -e

mkdir -p /run/liara

python3 /usr/local/bin/load_profile.py

if [ ! -z "$__VOLUME_PATH" ]; then
  echo 'Configuring volume...'
  chgrp -R www-data $__VOLUME_PATH
  chmod -R ug+rwx $__VOLUME_PATH
fi

# Start cron service
if [ ! -z "$__CRON" ]; then
  echo '[CRON] Starting...';
  supercronic ${SUPERCRONIC_OPTIONS} /run/liara/crontab &
fi

if [ -f /etc/supervisord.d/supervisor.conf ]; then
  echo '[SUPERVISOR] Starting...';
  supervisord -c /etc/supervisord.conf &
fi

exec "docker-php-entrypoint" "$@";

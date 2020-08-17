#!/bin/bash

# Is storage writable? In other words, is a disk mounted to the storage directory or its parents?
df | grep -q '/var/www/html/storage$' || df | grep -q '/var/www/html$' || df | grep -q '/var/www$' || df | grep -q '/var$'
if [[ $? == '0' ]]; then
  # echo '---------------- disk exists.'
  # Is symlink?
  if [[ -L "/var/www/html/storage/framework" ]]; then
    # echo '------------------- Removing symlink'
    rm /var/www/html/storage/framework
    mkdir /var/www/html/storage/framework
    cp -rp /var/www/.laravel-framework/* /var/www/html/storage/framework
  fi
else
  mkdir -p /tmp/.laravel-framework
  chown www-data:www-data /tmp/.laravel-framework
  if [[ -z "$(ls -A /tmp/.laravel-framework)" ]]; then
    # echo '----------------- copying .laravel-framework'
    cp -rp /var/www/.laravel-framework/* /tmp/.laravel-framework
  fi
fi

# Ensure bootstrap/cache points to a real directory
mkdir -p /tmp/.laravel-bootstrap-cache

# BEGIN: Laravel optimization
# We need to run this command inside entrypoint because access to runtime environment variables is required.
# If we run this command during the build phase, the app wont have access to any of its envs.
if [ "$__LARAVEL_CONFIGCACHE" = "true" ]; then
  php artisan config:cache
fi

if [ "$__LARAVEL_ROUTECACHE" = "true" ]; then
  php artisan route:cache
fi

chown -R www-data:www-data /tmp/.laravel-bootstrap-cache
# END: Laravel optimization

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
  supervisord -c /etc/supervisord.conf
fi

echo '[APACHE] Starting...';
exec "docker-php-entrypoint" "$@";

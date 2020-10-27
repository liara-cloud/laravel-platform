#!/bin/bash

set -ex

CURRENT_DIR=${BASH_SOURCE%/*}

# https://stackoverflow.com/a/10586169/6390238
IFS=',' read -r -a phpVersions <<< "$PHP_VERSIONS"

for PHP_VERSION in "${phpVersions[@]}"
do
  set +x
  echo '===================='
  echo 'PHP_VERSION' $PHP_VERSION
  echo '===================='
  set -x

  echo "FROM liararepo/laravel-platform:frontend
FROM liararepo/laravel-platform:php${PHP_VERSION}-backend" | docker build \
    -t laravel-80-test-image --build-arg "__LARAVEL_BUILDASSETS=false" -f - ${CURRENT_DIR}/fixtures/${FIXTURE}

  docker rm -f laravel-80-test || true
  docker run -d -p 2299:80 --name laravel-80-test --read-only --tmpfs /tmp --tmpfs /run  laravel-80-test-image
  sleep 5
  docker logs laravel-80-test
  output=$(curl --silent http://localhost:2299)
  echo "$output" | grep "Welcome to Laravel v${LARAVEL_VERSION}" || (echo 'Unexpected output for curl!' && exit 1)
  docker logs --tail 1 laravel-80-test | grep 'curl'

  # Check installed extensions
  docker exec -it laravel-80-test php -m > /tmp/php-exts
  diff -u --ignore-space-change --strip-trailing-cr --ignore-blank-lines ${CURRENT_DIR}/php${PHP_VERSION}-extensions /tmp/php-exts

  # Check php.ini config
  docker exec -it laravel-80-test php -i | grep 'max_execution_time => 0 => 0' # Default value
  docker exec -it laravel-80-test php -i | grep 'memory_limit => 4G => 4G' # Customized
  docker exec -it laravel-80-test php -i | grep 'upload_max_filesize => 1234M => 1234M' # Customized

  # Clean up
  echo '> Cleaning up...'
  docker rm -f laravel-80-test
  docker rmi laravel-80-test-image
done


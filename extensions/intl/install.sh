#!/usr/bin/env bash

set -e
export EXTENSION=intl
export DEV_DEPENDENCIES="libicu-dev"
export CONFIGURE_OPTIONS=" "

../docker-install.sh

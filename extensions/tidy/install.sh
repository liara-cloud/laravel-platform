#!/usr/bin/env bash

set -e
export EXTENSION=tidy
export DEV_DEPENDENCIES="libtidy-dev"
export DEPENDENCIES="libtidy5"

../docker-install.sh

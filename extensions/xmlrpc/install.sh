#!/usr/bin/env bash

set -e
export EXTENSION=xmlrpc
export DEV_DEPENDENCIES="libxml2-dev"
export DEPENDENCIES="libxml2"

../docker-install.sh

#!/bin/bash

function run {
    echo "$*"
    eval $*
}

# .env file
envfile=${ENTRYPOINT_ENVFILE:=/var/openfaas/secrets/dotenv}
if [ -e "$envfile" ]; then
    run cp $envfile .env
else
    prefix=${ENTRYPOINT_PREFIX:=DOTENV_}
    env | grep "^$prefix" | sed "s/^$prefix//gi;" > .env

    c=$(wc -l .env | cut -f1 -d" ")
    if [ $c == 0 ]; then
        run cp .env.example .env
        run php artisan key:generate
    fi
fi

# Check against tmp
tmpapp="/tmp/app"
run mkdir -p $tmpapp
run cp -R storage $tmpapp/storage

# Debug
if [ "$ENTRYPOINT_DEBUG" ]; then
    # Host info
    run hostname
    run whoami
    echo "prefix: $prefix"
    echo
    run env
    echo
    run cat .env
    echo
    run df -h
    echo
    run "find /tmp"
    echo
    run php debug.php
    echo
    run sed -is "s/CHANNEL_LOG/#CHANNEL_LOG/gi" .env
else
    run php artisan config:cache
fi

run $*

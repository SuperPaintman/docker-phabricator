#!/bin/bash

#
# Author:       SuperPaintman <SuperPaintmanDeveloper@gmail.com>
#

set -e

###
# Constants
###
RETVAL=0

CCYAN="\033[0;36m"
CGREEN="\033[0;32m"
CYELLOW="\033[0;33m"
CBLUE="\033[0;34m"
CGRAY="\033[1;30m"
CNC="\033[0m"

###
# Decorate php-fpm
###
if [ "$1" == php-fpm ]; then
    ###
    # Copy files
    ###
    # libphutil
    if ! [ "$(ls -A /var/www/libphutil)" ]; then
        echo "${CGREEN}Copy${CNC}: ${CBLUE}/usr/src/phabricator/libphutil${CNC} -> ${CBLUE}/var/www/libphutil${CNC}"
        mkdir -p /var/www/libphutil
        cp -avr /usr/src/phabricator/libphutil/* /var/www/libphutil 1> /dev/mull
    else
        echo "${CGREEN}libpgutil${CNC} already exitis: ${CBLUE}/var/www/libphutil${CNC}"
        echo "${CYELLOW}note${CNC}: If this is the first launch and Phabricator not working, try remove all from this folder"
    fi

    # arcanist
    if ! [ "$(ls -A /var/www/arcanist)" ]; then
        echo "${CGREEN}Copy${CNC}: ${CBLUE}/usr/src/phabricator/arcanist${CNC} -> ${CBLUE}/var/www/arcanist${CNC}"
        mkdir -p /var/www/arcanist
        cp -avr /usr/src/phabricator/arcanist/* /var/www/arcanist 1> /dev/null
    else
        echo "${CGREEN}arcanist${CNC} already exitis: ${CBLUE}/var/www/arcanist${CNC}"
        echo "${CYELLOW}note${CNC}: If this is the first launch and Phabricator not working, try remove all from this folder"
    fi

    # phabricator
    if ! [ "$(ls -A /var/www/phabricator)" ]; then
        echo "${CGREEN}Copy${CNC}: ${CBLUE}/usr/src/phabricator/phabricator${CNC} -> ${CBLUE}/var/www/phabricator${CNC}"
        mkdir -p /var/www/phabricator
        cp -avr /usr/src/phabricator/phabricator/* /var/www/phabricator 1> /dev/null
    else
        echo "${CGREEN}phabricator${CNC} already exitis: ${CBLUE}/var/www/phabricator${CNC}"
        echo "${CYELLOW}note${CNC}: If this is the first launch and Phabricator not working, try remove all from this folder"
    fi

    ###
    # Main settings
    ###
    # Base uri
    if [ ! -z "$PHABRICATOR_BASEURI" ]; then
        echo "${CGREEN}set phabricator.base-uri${CNC}: ${CBLUE}$PHABRICATOR_BASEURI${CNC}"
        ./bin/config set phabricator.base-uri "$PHABRICATOR_BASEURI"
    else
        echo "${CYELLOW}warn${CNC}: missing ${CBLUE}PHABRICATOR_BASEURI${CNC} environment variables"
    fi

    # Storage local disk path
    if [ ! -z "$PHABRICATOR_STORAGE_LOCAL_DISK_PATH" ]; then
        echo "${CGREEN}set storage.local-disk.path${CNC}: ${CBLUE}$PHABRICATOR_STORAGE_LOCAL_DISK_PATH${CNC}"
        ./bin/config set storage.local-disk.path "$PHABRICATOR_STORAGE_LOCAL_DISK_PATH"
    else
        echo "${CYELLOW}warn${CNC}: missing ${CBLUE}PHABRICATOR_STORAGE_LOCAL_DISK_PATH${CNC} environment variables"
    fi

    # Repo local disk path
    if [ ! -z "$PHABRICATOR_REPO_LOCAL_DISK_PATH" ]; then
        echo "${CGREEN}set repository.default-local-path${CNC}: ${CBLUE}$PHABRICATOR_REPO_LOCAL_DISK_PATH${CNC}"
        ./bin/config set repository.default-local-path "$PHABRICATOR_REPO_LOCAL_DISK_PATH"
    else
        echo "${CYELLOW}warn${CNC}: missing ${CBLUE}PHABRICATOR_REPO_LOCAL_DISK_PATH${CNC} environment variables"
    fi

    ###
    # DB settings
    ###
    # Host
    if [ ! -z "$PHABRICATOR_DB_HOST" ]; then
        echo "${CGREEN}set mysql.host${CNC}: ${CBLUE}$PHABRICATOR_DB_HOST${CNC}"
        ./bin/config set mysql.host "$PHABRICATOR_DB_HOST"
    else
        echo "${CYELLOW}warn${CNC}: missing ${CBLUE}PHABRICATOR_DB_HOST${CNC} environment variables"
    fi

    # Port
    if [ ! -z "$PHABRICATOR_DB_PORT" ]; then
        echo "${CGREEN}set mysql.port${CNC}: ${CBLUE}$PHABRICATOR_DB_PORT${CNC}"
        ./bin/config set mysql.port "$PHABRICATOR_DB_PORT"
    else
        echo "${CYELLOW}warn${CNC}: missing ${CBLUE}PHABRICATOR_DB_PORT${CNC} environment variables"
    fi

    # User
    if [ ! -z "$PHABRICATOR_DB_USER" ]; then
        echo "${CGREEN}set mysql.user${CNC}: ${CBLUE}$PHABRICATOR_DB_USER${CNC}"
        ./bin/config set mysql.user "$PHABRICATOR_DB_USER"
    else
        echo "${CYELLOW}warn${CNC}: missing ${CBLUE}PHABRICATOR_DB_USER${CNC} environment variables"
    fi

    # Pass
    if [ ! -z "$PHABRICATOR_DB_PASS" ]; then
        echo "${CGREEN}set mysql.pass${CNC}: ${CBLUE}$PHABRICATOR_DB_PASS${CNC}"
        ./bin/config set mysql.pass "$PHABRICATOR_DB_PASS"
    else
        echo "${CYELLOW}warn${CNC}: missing ${CBLUE}PHABRICATOR_DB_PASS${CNC} environment variables"
    fi

    ###
    # DB Update
    ###
    echo "${CGREEN}Update DB${CNC}"
    ./bin/storage upgrade --force

    ###
    # Start daemons
    ###
    echo "${CGREEN}Start daemons${CNC}"
    ./bin/phd start
fi

exec "$@"

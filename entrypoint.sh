#!/bin/bash
set -e

#
# Author:       SuperPaintman <SuperPaintmanDeveloper@gmail.com>
#

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
    # Main settings
    ###
    # Base uri
    if [ ! -z "$PHABRICATOR_BASEURI" ]; then
        echo "${CGREEN}set base-uri${CNC}: ${CBLUE}$PHABRICATOR_BASEURI${CNC}"
        ./bin/config set phabricator.base-uri "$PHABRICATOR_BASEURI"
    else
        echo "${CYELLOW}warn${CNC}: missing ${CBLUE}PHABRICATOR_BASEURI${CNC} environment variables"
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

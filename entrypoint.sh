#!/bin/sh

if [ $# = 0 ]; then
    # Wait for the config to appear, then start
    if [ ! -e "$GCP_CONFIG_DIR/config" ]; then
        printf "Waiting for configuration to be created...\\n"
        sleep 5
        while [ ! -e "$GCP_CONFIG_DIR/config" ]; do
            sleep 5
        done
        printf "Config created, starting...\\n"
    fi
    exec /opt/globusconnectpersonal/globusconnectpersonal -start
else
    if [ "$1" = "setup" ]; then
        exec /opt/globusconnectpersonal/globusconnectpersonal -setup
    elif [ "$1" = "start" ]; then
        exec /opt/globusconnectpersonal/globusconnectpersonal -start
    elif [ $(type -t "$1") = file ]; then
        exec "$@"
    else
        printf "$1: command not found\\n"
        exit 127
    fi
fi

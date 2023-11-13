#!/bin/sh

set -eu

log(){
    FMT="$1"
    shift
    printf -- "$FMT\\n" "$@" >&2
}

if [ $# = 0 ]; then
    # Wait for the config to appear before starting
    # This gives the user a chance to exec into the container and run "setup"
    if [ ! -e "/var/lib/globus/lta/config" ]; then
        log "Waiting for configuration to be created..."
        sleep 5
        while [ ! -e "/var/lib/globus/lta/config" ]; do
            sleep 5
        done
        log "Config created"
    fi

    # If the environment variable is set, write it to the config-paths file
    if [ ! -z "${GLOBUS_PATHS:-}" ]; then
        log "Updating config-paths:\\n%s" "$GLOBUS_PATHS"
        printf -- "%s" "$GLOBUS_PATHS" > "/var/lib/globus/lta/config-paths"
    fi

    exec /opt/globusconnectpersonal/globusconnectpersonal -dir /var/lib/globus -start
else
    if [ "$1" = "start" ]; then
        # Run it immediately
        exec /opt/globusconnectpersonal/globusconnectpersonal -dir /var/lib/globus -start
    elif type "$1" >/dev/null 2>&1; then
        # This allows running alternative commands through the entrypoint
        exec "$@"
    else
        log "$1: command not found"
        exit 127
    fi
fi

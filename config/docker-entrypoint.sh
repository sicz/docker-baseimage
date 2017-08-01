#!/bin/bash -e

################################################################################

# Run extra entrypoints
if [ -e /docker-entrypoint.d ]; then
  for DOCKER_ENTRYPOINT in /docker-entrypoint.d/*.sh; do
    . ${DOCKER_ENTRYPOINT}
  done
  unset DOCKER_ENTRYPOINT
fi

################################################################################

debug "Raw command: $@"
eval info "Executing command: $@"
eval exec "$@"

################################################################################

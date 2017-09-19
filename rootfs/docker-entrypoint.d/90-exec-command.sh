#!/bin/bash -e

################################################################################

# Container is starting
if [ -n "${DOCKER_CONTAINER_START}" ]; then
  # Wait for another services
  : ${WAIT_FOR_TIMEOUT:=60}
  wait_for_dns ${WAIT_FOR_DNS_TIMEOUT:=${WAIT_FOR_TIMEOUT}} ${WAIT_FOR_DNS}
  wait_for_tcp ${WAIT_FOR_TCP_TIMEOUT:=${WAIT_FOR_TIMEOUT}} ${WAIT_FOR_TCP}
  wait_for_url ${WAIT_FOR_URL_TIMEOUT:=${WAIT_FOR_TIMEOUT}} ${WAIT_FOR_URL}

  # Run as specified user
  if [ -n "${DOCKER_USER}" ]; then
    set -- su-exec ${DOCKER_USER} "$@"
  fi
fi

################################################################################

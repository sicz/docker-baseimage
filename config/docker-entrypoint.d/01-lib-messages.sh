#!/bin/bash -e

################################################################################
# Format message
msg() {
  local LEVEL=$1; shift
  local ENTRYPOINT=$1; shift
  local TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  ENTRYPOINT=$(basename ${ENTRYPOINT})

  echo "$(printf "[%-25s][%-5s][%-25s] $*" ${TIMESTAMP} ${LEVEL} ${ENTRYPOINT})"
}

################################################################################
# Message with severity
error() {
  msg "ERROR" ${DOCKER_ENTRYPOINT:-$0} $*
}

warn() {
  msg "WARN" ${DOCKER_ENTRYPOINT:-$0} $*
}

info() {
  if [ -n "${DOCKER_ENTRYPOINT_INFO}" -o -n "${DOCKER_ENTRYPOINT_DEBUG}" ]; then
    msg "INFO" ${DOCKER_ENTRYPOINT:-$0} $*
  fi
}

debug() {
  if [ -n "${DOCKER_ENTRYPOINT_DEBUG}" ]; then
    msg "DEBUG" ${DOCKER_ENTRYPOINT:-$0} $*
  fi
}

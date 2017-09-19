#!/bin/bash -e

################################################################################

# URL Regex pattern:
# \1 - http://hostname:port
# \2 - http://
# \3 - http
# \4 - hostname:port
# \5 - hostname
# \6 - :port
# \7 - port
# \8 - /path?query
# \9 - /path
URL_PATTERN="((([a-zA-Z]+)://)?(([a-zA-Z0-9._-]+|\[[0-9a-fA-F:.]+\])(:([0-9]+))?))(.*)"

################################################################################

# Default timeouts for wait_for_* functions
: ${WAIT_FOR_TIMEOUT:=60}
: ${WAIT_FOR_DNS_TIMEOUT:=${WAIT_FOR_TIMEOUT}}
: ${WAIT_FOR_TCP_TIMEOUT:=${WAIT_FOR_TIMEOUT}}
: ${WAIT_FOR_URL_TIMEOUT:=${WAIT_FOR_TIMEOUT}}

################################################################################

# Wait for DNS name resolution
wait_for_dns () {
  local URL
  local HOST
  local TIMEOUT=$1; shift
  for URL in $*; do
    # Extract hostname from URL
    HOST=$(sed -E "s;^${URL_PATTERN}$;\5;" <<< "${URL}")
    local i=0
    local after
    local before="$(date "+%s")"
    while ! getent ahosts ${HOST:=localhost} >/dev/null 2>&1; do
      if [ ${i} -eq 0 ]; then
        info "Waiting for ${HOST} name resolution up to ${TIMEOUT}s"
      fi
      after="$(date "+%s")"
      i=$((i+1+after-before))
      before="${after}"
      if [ ${i} -gt ${TIMEOUT} ]; then
        error "${HOST} name resolution timed out after ${i}s"
        exit 1
      fi
      sleep 1
    done
    if [ ${i} -gt 0 ]; then
      info "Got the ${HOST} address $(
        getent ahosts ${HOST} |
        grep "STREAM ${HOST}" |
        cut -d ' ' -f 1 |
        tr "\n" "," |
        sed -E "s/,$//"
      ) in ${i}s"
    else
      debug "Got the ${HOST} address $(
        getent ahosts ${HOST} |
        grep "STREAM ${HOST}" |
        cut -d ' ' -f 1 |
        tr "\n" "," |
        sed -E "s/,$//"
      ) in ${i}s"
    fi
  done
}

################################################################################

# Wait for TCP connection
wait_for_tcp () {
  local URL
  local HOST
  local PORT
  local TIMEOUT=$1; shift
  for URL in $*; do
    # Extract hostname and TCP port from URL
    PROTO=$(sed -E "s;^${URL_PATTERN}$;\3;" <<< "${URL}")
    HOST=$(sed -E "s;^${URL_PATTERN}$;\5;" <<< "${URL}")
    PORT=$(sed -E "s;^${URL_PATTERN}$;\7;" <<< "${URL}")
    case "${PROTO}" in
    https)
      : ${PORT:=443} ;;
    *)
      : ${PORT:=80} ;;
    esac
    wait_for_dns ${TIMEOUT} ${HOST}
    local i=0
    local after
    local before="$(date "+%s")"
    while ! ncat -z ${HOST:=localhost} ${PORT:=80} >/dev/null 2>&1; do
      if [ ${i} -eq 0 ]; then
        info "Waiting for the connection to tcp://${HOST}:${PORT} up to ${TIMEOUT}s"
      fi
      after="$(date "+%s")"
      i=$((i+1+after-before))
      before="${after}"
      if [ ${i} -gt ${TIMEOUT} ]; then
        error "Connection to tcp://${HOST}:${PORT} timed out after ${i}s"
        exit 1
      fi
      sleep 1
    done
    if [ ${i} -gt 0 ]; then
      info "Got the connection to tcp://${HOST}:${PORT} in ${i}s"
    else
      debug "Got the connection to tcp://${HOST}:${PORT} in ${i}s"
    fi
  done
}

################################################################################

# Wait for URL connection
wait_for_url () {
  local URL
  local TIMEOUT=$1; shift
  for URL in $*; do
    wait_for_dns ${TIMEOUT} ${URL}
    local i=0
    local after
    local before="$(date "+%s")"
    while ! curl -fksS ${URL} >/dev/null 2>&1; do
      if [ ${i} -eq 0 ]; then
        info "Waiting for the connection to ${URL} up to ${TIMEOUT}s"
      fi
      after="$(date "+%s")"
      i=$((i+1+after-before))
      before="${after}"
      if [ ${i} -gt ${TIMEOUT} ]; then
        error "Connection to ${URL} timed out after ${i}s"
        exit 1
      fi
      sleep 1
    done
    if [ ${i} -gt 0 ]; then
      info "Got the connection to ${URL} in ${i}s"
    else
      debug "Got the connection to ${URL} in ${i}s"
    fi
  done
}

################################################################################

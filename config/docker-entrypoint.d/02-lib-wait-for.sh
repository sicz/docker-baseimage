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
    #while ! nslookup ${HOST:=localhost} >/dev/null 2>&1; do
    while ! getent ahosts ${HOST:=localhost} >/dev/null 2>&1; do
      if [ $i -eq 0 ]; then
        info "Waiting for ${HOST} name resolution up to ${TIMEOUT}s"
      fi
      i=$((i+1))
      if [ $i -gt ${TIMEOUT} ]; then
        error "${HOST} name resolution timeout ${TIMEOUT}s has just expired"
        exit 1
      fi
      sleep 1
    done
    if [ $i -gt 0 ]; then
      info "Got ${HOST} address $(
        getent ahosts ${HOST} |
        grep "STREAM ${HOST}" |
        cut -d ' ' -f 1 |
        tr "\n" "," |
        sed -E "s/,$//"
      ) in ${i}s"
    else
      debug "Got ${HOST} address $(
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
    HOST=$(sed -E "s;^${URL_PATTERN}$;\5;" <<< "${URL}")
    PORT=$(sed -E "s;^${URL_PATTERN}$;\7;" <<< "${URL}")
    wait_for_dns ${TIMEOUT} ${HOST}
    local i=0
    while ! ncat -z ${HOST:=localhost} ${PORT:=80} >/dev/null 2>&1; do
      if [ $i -eq 0 ]; then
        info "Waiting for connection to tcp://${HOST}:${PORT} up to ${TIMEOUT}s"
      fi
      i=$((i+1))
      if [ $i -gt ${TIMEOUT} ]; then
        error "tcp://${HOST} connection timeout ${TIMEOUT}s has just expired"
        exit 1
      fi
      sleep 1
    done
    if [ $i -gt 0 ]; then
      info "Got a connection to tcp://${HOST}:${PORT} in ${i}s"
    else
      debug "Got a connection to tcp://${HOST}:${PORT} in ${i}s"
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
    while ! curl -fksS ${URL} >/dev/null 2>&1; do
      if [ $i -eq 0 ]; then
        info "Waiting for connection to ${URL} up to ${TIMEOUT}s"
      fi
      i=$((i+1))
      if [ $i -gt ${TIMEOUT} ]; then
        error "${URL} connection timeout ${TIMEOUT}s has just expired"
        exit 1
      fi
      sleep 1
    done
    if [ $i -gt 0 ]; then
      info "Got a connection to ${URL} in ${i}s"
    else
      debug "Got a connection to ${URL} in ${i}s"
    fi
  done
}

################################################################################

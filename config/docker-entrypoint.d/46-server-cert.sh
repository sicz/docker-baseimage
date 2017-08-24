#!/bin/bash -e

################################################################################

# Set certificate, private key and passphrase files permission
if [ -e "${SERVER_CRT_FILE}" ]; then
  if [ -n "${SERVER_CRT_FILE_OWNER}" ]; then
    debug "Changing owner of ${SERVER_CRT_FILE} to ${SERVER_CRT_FILE_OWNER}"
    chown ${SERVER_CRT_FILE_OWNER} ${SERVER_CRT_FILE}
  fi
  debug "Changing mode of ${SERVER_CRT_FILE} to ${SERVER_CRT_FILE_MODE}"
  chmod ${SERVER_CRT_FILE_MODE} ${SERVER_CRT_FILE}
fi
if [ -e "${SERVER_KEY_FILE}" ]; then
  if [ -n "${SERVER_KEY_FILE_OWNER}" ]; then
    debug "Changing owner of ${SERVER_KEY_FILE} to ${SERVER_KEY_FILE_OWNER}"
    chown ${SERVER_KEY_FILE_OWNER} ${SERVER_KEY_FILE}
  fi
  debug "Changing mode of ${SERVER_KEY_FILE} to ${SERVER_KEY_FILE_MODE}"
  chmod ${SERVER_KEY_FILE_MODE} ${SERVER_KEY_FILE}
fi
if [ -e "${SERVER_KEY_PWD_FILE}" ]; then
  if [ -n "${SERVER_KEY_FILE_OWNER}" ]; then
    debug "Changing owner of ${SERVER_KEY_PWD_FILE} to ${SERVER_KEY_FILE_OWNER}"
    chown ${SERVER_KEY_FILE_OWNER} ${SERVER_KEY_PWD_FILE}
  fi
  debug "Changing mode of ${SERVER_KEY_PWD_FILE} to ${SERVER_KEY_FILE_MODE}"
  chmod ${SERVER_KEY_FILE_MODE} ${SERVER_KEY_PWD_FILE}
fi

################################################################################

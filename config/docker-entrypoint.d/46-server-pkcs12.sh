#!/bin/bash -e

################################################################################

# Convert server certificate and private key into PKCS12 file
if [ -e "${SERVER_CRT_FILE}" -a -e "${SERVER_KEY_FILE}" ]; then
  if [ -n "${SERVER_P12_FILE}" -a ! -e "${SERVER_P12_FILE}" ]; then
    if [ -z "${SERVER_KEY_PWD}" ]; then
      if [ -e "${SERVER_KEY_PWD_FILE}" ]; then
        info "Using server private key passphrase from ${SERVER_KEY_PWD_FILE}"
        SERVER_KEY_PWD=$(cat ${SERVER_KEY_PWD_FILE})
      else
        error "Missing CA key passphrase file ${SERVER_KEY_PWD_FILE}"
        exit 1
      fi
    fi
    info "Creating server PKCS12 file ${SERVER_P12_FILE}"
    openssl pkcs12 -export \
      -in ${SERVER_CRT_FILE} \
      -inkey ${SERVER_KEY_FILE} \
      -passin "pass:${SERVER_KEY_PWD}" \
      -passout "pass:${SERVER_KEY_PWD}" \
      -out ${SERVER_P12_FILE}
    # Set server PKCS12 file permissions
    if [ -n "${SERVER_KEY_FILE_OWNER}" ]; then
      debug "Changing owner of ${SERVER_P12_FILE} to ${SERVER_KEY_FILE_OWNER}"
      chown ${SERVER_KEY_FILE_OWNER} ${SERVER_P12_FILE}
    fi
    debug "Changing mode of ${SERVER_P12_FILE} to ${SERVER_KEY_FILE_MODE}"
    chmod ${SERVER_KEY_FILE_MODE} ${SERVER_P12_FILE}
  fi
fi

################################################################################

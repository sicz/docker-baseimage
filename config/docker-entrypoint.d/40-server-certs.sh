#!/bin/bash -e

# Use Simple-CA to get server certificate
if [ -n "${SIMPLE_CA_URL}" ]; then

  # Wait for Simple CA
  wait_for_url ${SIMPLE_CA_TIMEOUT:-60} ${SIMPLE_CA_URL}/ca.pem

  # Get root CA certificate
  if [ ! -e ${CA_CRT} ]; then
    info "Getting root CA certificate from ${SIMPLE_CA_URL}/ca.pem"
    curl -fksS ${SIMPLE_CA_URL}/ca.pem > ${CA_CRT}
  else
    info "Using root CA certificate ${CA_CRT}"
  fi

  # Create server private key and certificate
  if [ ! -e ${SERVER_CRT} ]; then
    if [ ! -e ${CA_USER_PWD_FILE} ]; then
      error "Missing CA user password ${CA_USER_PWD_FILE}"
      exit 1
    fi
    info "Creating server private key ${SERVER_KEY}"
    info "Creating server certificate ${SERVER_CRT}"
    # Subject alternative names
    SERVER_CRT_NAMES="${HOSTNAME},localhost,${SERVER_CRT_NAMES}"
    # Container IPv4 addresses
    SERVER_CRT_IP=$(
      ifconfig |
      grep "inet addr:" |
      sed -E "s/.*inet addr:([^ ]*).*/\1/" |
      tr "\n" "," |
      sed "s/,$//"
    )
    # Server private key passphrase
    if [ -e "${SERVER_KEY_PWD_FILE}" ]; then
      info "Using server private key passphrase ${SERVER_KEY_PWD_FILE}"
      SERVER_KEY_PWD=$(cat ${SERVER_KEY_PWD_FILE})
    else
      info "Creating random server private key passphrase"
      SERVER_KEY_PWD=$(openssl rand -hex 32)
    fi
    # Create server private key and certificate
    openssl req -newkey rsa:2048 \
      -subj "/${SERVER_CRT_SUBJECT}" \
      -keyout "${SERVER_KEY}" \
      -passout "pass:${SERVER_KEY_PWD}" |
    curl -fsS \
      --cacert "${CA_CRT}" \
      --user "${CA_USER}:$(cat ${CA_USER_PWD_FILE})"
      --data-binary @- \
      --output "${SERVER_CRT}" \
      "${SIMPLE_CA_URL}/sign?dn=${SERVER_CRT_SUBJECT}&dns=${SERVER_CRT_NAMES}&ip=${SERVER_CRT_IP}&oid=${SERVER_CRT_OID}"
    # Set server private key permissions
    if [ -n "${DOCKER_USER}" ]; then
      chown ${DOCKER_USER}:${DOCKER_USER} ${SERVER_KEY}
    fi
    chmod o-rwx ${SERVER_KEY}
  fi

  # Convert server private key and certificate to pkcs12
  if [ -n "${SERVER_P12}" -a ! -e ${SERVER_P12} ]; then
    info "Creating server PKCS12 file ${SERVER_P12}"
    openssl pkcs12 -export \
      -in ${SERVER_CRT} \
      -inkey ${SERVER_KEY} \
      -passin "pass:${SERVER_KEY_PWD}" \
      -passout "pass:${SERVER_KEY_PWD}" \
      -out ${SERVER_P12}
    # Set server pkcs12 permissions
    if [ -n "${DOCKER_USER}" ]; then
      chown ${DOCKER_USER}:${DOCKER_USER} ${SERVER_P12}
    fi
    chmod o-rwx ${SERVER_P12}
  fi
fi

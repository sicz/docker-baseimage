#!/bin/bash -e

################################################################################

# Use Simple-CA to get server certificate
if [ -n "${SIMPLE_CA_URL}" ]; then

  # Create server private key and certificate
  if [ ! -e "${SERVER_CRT_FILE}" ]; then

    # Wait for Simple CA
    wait_for_url ${SIMPLE_CA_TIMEOUT:-60} ${SIMPLE_CA_URL}/ca.pem

    # Get root CA certificate
    if [ ! -e "${CA_CRT_FILE}" ]; then
      info "Getting root CA certificate from ${SIMPLE_CA_URL}/ca.pem"
      curl -fksS ${SIMPLE_CA_URL}/ca.pem > ${CA_CRT_FILE}
    else
      info "Using root CA certificate from ${CA_CRT_FILE}"
    fi

    if [ -e "${CA_USER_NAME_FILE}" ]; then
      info "Using CA user name from ${CA_USER_NAME_FILE}"
      CA_USER_NAME=$(cat ${CA_USER_NAME_FILE})
    fi
    if [ -z "${CA_USER_NAME}" ]; then
      error "Missing CA user name"
      exit 1
    fi
    if [ -e "${CA_USER_PWD_FILE}" ]; then
      info "Using CA user password from ${CA_USER_PWD_FILE}"
      CA_USER_PWD=$(cat ${CA_USER_PWD_FILE})
    fi
    if [ -z "${CA_USER_PWD}" ]; then
      error "Missing CA user password"
      exit 1
    fi
    # Subject alternative names
    info "Creating server certificate file ${SERVER_CRT_FILE}"
    SERVER_CRT_HOST="${SERVER_CRT_HOST},${DOCKER_CONTAINER_NAME},${HOSTNAME},localhost"
    # Container IPv4 addresses
    SERVER_CRT_IP="${SERVER_CRT_IP},$(
      ifconfig |
      egrep "<?inet>?" |
      sed -E "s/.*inet (addr:)?([^ ]*).*/\2/" |
      tr "\n" "," |
      sed "s/,$//"
    )"
    info "DN:  ${SERVER_CRT_SUBJECT}"
    info "DNS: ${SERVER_CRT_HOST}"
    info "IP:  ${SERVER_CRT_IP}"
    info "OID: ${SERVER_CRT_OID}"
    # Server private key passphrase
    info "Creating server private key in ${SERVER_KEY_FILE}"
    if [ -e "${SERVER_KEY_PWD_FILE}" ]; then
      info "Using server private key passphrase from ${SERVER_KEY_PWD_FILE}"
      SERVER_KEY_PWD=$(cat ${SERVER_KEY_PWD_FILE})
    else
      info "Creating random server private key passphrase"
      SERVER_KEY_PWD=$(openssl rand -hex 32)
    fi
    # Create server private key and certificate
    openssl req -newkey rsa:2048 \
      -subj "/${SERVER_CRT_SUBJECT}" \
      -keyout "${SERVER_KEY_FILE}" \
      -passout "pass:${SERVER_KEY_PWD}" |
    curl -fsS \
      --cacert "${CA_CRT_FILE}" \
      --user "${CA_USER_NAME}:${CA_USER_PWD}" \
      --data-binary @- \
      --output "${SERVER_CRT_FILE}" \
      "${SIMPLE_CA_URL}/sign?dn=${SERVER_CRT_SUBJECT}&dns=${SERVER_CRT_HOST}&ip=${SERVER_CRT_IP}&rid=${SERVER_CRT_OID}"
    # Set server private key permissions
    if [ -n "${DOCKER_USER}" ]; then
      info "Changing owner of ${SERVER_KEY_FILE} to ${DOCKER_USER}"
      chown ${DOCKER_USER}:${DOCKER_USER} ${SERVER_KEY_FILE}
    fi
    chmod o-rwx ${SERVER_KEY_FILE}
  fi

  # Convert server private key and certificate into PKCS12 file
  if [ -n "${SERVER_P12_FILE}" -a ! -e "${SERVER_P12_FILE}" ]; then
    info "Creating server PKCS12 file in ${SERVER_P12_FILE}"
    openssl pkcs12 -export \
      -in ${SERVER_CRT_FILE} \
      -inkey ${SERVER_KEY_FILE} \
      -passin "pass:${SERVER_KEY_PWD}" \
      -passout "pass:${SERVER_KEY_PWD}" \
      -out ${SERVER_P12_FILE}
    # Set server PKCS12 file permissions
    if [ -n "${DOCKER_USER}" ]; then
      info "Changing owner of ${SERVER_P12_FILE} to ${DOCKER_USER}"
      chown ${DOCKER_USER}:${DOCKER_USER} ${SERVER_P12_FILE}
    fi
    chmod o-rwx ${SERVER_P12_FILE}
  fi
fi

################################################################################

# Create CA certificate fingerprint link to /etc/ssl/certs
CA_CRT_HASH_FILE="/etc/ssl/certs/$(openssl x509 -hash -noout -in ${CA_CRT_FILE}).0"
if [ -n "${CA_CRT_FILE}" -a -e "${CA_CRT_FILE}" -a ! -e "${CA_CRT_HASH_FILE}" ]; then
  info "Creating CA certificate hash link server ${CA_CRT_HASH_FILE}"
  ln -s ${CA_CRT_FILE} ${CA_CRT_HASH_FILE}
fi

################################################################################

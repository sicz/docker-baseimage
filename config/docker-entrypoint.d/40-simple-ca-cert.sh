#!/bin/bash -e

################################################################################

# Use Simple CA to get server certificate
if [ -n "${SIMPLE_CA_URL}" ]; then

  # Create server private key and certificate
  if [ ! -e "${SERVER_CRT_FILE}" ]; then

    # Create directories
    mkdir -p ${CA_CRT_DIR} ${SERVER_CRT_DIR} ${SERVER_KEY_DIR}

    # Wait for CA
    wait_for_url ${SIMPLE_CA_TIMEOUT:-60} ${SIMPLE_CA_URL}/ca.crt

    # Get CA certificate
    if [ ! -e "${CA_CRT_FILE}" ]; then
      info "Copying CA certificate from ${SIMPLE_CA_URL}/ca.crt to ${CA_CRT_FILE}"
      curl -fksS ${SIMPLE_CA_URL}/ca.crt > ${CA_CRT_FILE}
    else
      info "Using CA certificate from ${CA_CRT_FILE}"
    fi

    # Get CA user name
    if [ -e "${CA_USER_NAME_FILE}" ]; then
      info "Using CA user name from ${CA_USER_NAME_FILE}"
      CA_USER_NAME=$(cat ${CA_USER_NAME_FILE})
    elif [ -z "${CA_USER_NAME}" ]; then
      error "Missing CA user name file ${CA_USER_NAME_FILE}"
      exit 1
    fi

    # Get CA user password
    if [ -e "${CA_USER_PWD_FILE}" ]; then
      info "Using CA user password from ${CA_USER_PWD_FILE}"
      CA_USER_PWD=$(cat ${CA_USER_PWD_FILE})
    elif [ -z "${CA_USER_NAME}" ]; then
      error "Missing CA user password file ${CA_USER_PWD_FILE}"
      exit 1
    fi

    # Get server private key passphrase
    info "Creating server private key file ${SERVER_KEY_FILE}"
    if [ -e "${SERVER_KEY_PWD_FILE}" ]; then
      info "Using server private key passphrase from ${SERVER_KEY_PWD_FILE}"
      SERVER_KEY_PWD=$(cat ${SERVER_KEY_PWD_FILE})
    else
      info "Creating random server private key passphrase"
      SERVER_KEY_PWD=$(openssl rand -hex 32)
    fi

    # Get server certificate attributes
    info "Creating server certificate file ${SERVER_CRT_FILE}"
    SERVER_CRT_REQ_HOST="${SERVER_CRT_HOST},${DOCKER_CONTAINER_NAME},${HOSTNAME},localhost"
    SERVER_CRT_REQ_IP="${SERVER_CRT_IP},$(
      ifconfig |
      egrep "<?inet>?" |
      sed -E "s/.*inet (addr:)?([^ ]*).*/\2/" |
      tr "\n" "," |
      sed "s/,$//"
    )"
    debug "DN:  ${SERVER_CRT_SUBJECT}"
    debug "DNS: ${SERVER_CRT_REQ_HOST}"
    debug "IP:  ${SERVER_CRT_REQ_IP}"
    debug "OID: ${SERVER_CRT_OID}"

    # Create server private key and certificate
    openssl req \
      -subj "/${SERVER_CRT_SUBJECT}" \
      -newkey rsa:2048 \
      -keyout "${SERVER_KEY_FILE}" \
      -passout "pass:${SERVER_KEY_PWD}" | \
    curl -fsS \
      --cacert "${CA_CRT_FILE}" \
      --user "${CA_USER_NAME}:${CA_USER_PWD}" \
      --data-binary @- \
      --output "${SERVER_CRT_FILE}" \
      "${SIMPLE_CA_URL}/sign?dn=${SERVER_CRT_SUBJECT}&dns=${SERVER_CRT_REQ_HOST}&ip=${SERVER_CRT_REQ_IP}&rid=${SERVER_CRT_OID}"
  fi
fi

################################################################################

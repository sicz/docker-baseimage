#!/bin/bash -e

################################################################################

# Default directory locations
: ${SERVER_CRT_DIR:=/etc/ssl/certs}
: ${SERVER_KEY_DIR:=/etc/ssl/private}
mkdir -p ${SERVER_CRT_DIR} ${SERVER_KEY_DIR}

################################################################################

# Default CA certificate file location
if [ -e /run/secrets/ca_crt.pem ]; then
  : ${CA_CRT_FILE:=/run/secrets/ca_crt.pem}
else
  : ${CA_CRT_FILE:=${SERVER_CRT_DIR}/ca_crt.pem}
fi

################################################################################

# Default trusted CA certificates bundle
if [ -e /etc/pki/tls/certs/ca-bundle.crt ]; then
  # CentOS trusted CA certificates bundle
  : ${CA_CRT_BUNDLE_FILE:=/etc/pki/tls/certs/ca-bundle.crt}
fi
: ${CA_CRT_BUNDLE_FILE:=/etc/ssl/certs/ca-certificates.crt}

################################################################################

# Default server certificate subject
: ${SERVER_CRT_SUBJECT:=CN=${DOCKER_CONTAINER_NAME}}

# Default server certificate file location
if [ -e /run/secrets/server_crt.pem ]; then
  : ${SERVER_CRT_FILE:=/run/secrets/server_crt.pem}
else
  : ${SERVER_CRT_FILE:=${SERVER_CRT_DIR}/server_crt.pem}
fi

# Default server private key file location
if [ -e /run/secrets/server_key.pem ]; then
  : ${SERVER_KEY_FILE:=/run/secrets/server_key.pem}
else
  : ${SERVER_KEY_FILE:=${SERVER_KEY_DIR}/server_key.pem}
fi

# Default server private key passphrase file location
if [ -e /run/secrets/server_key.pwd ]; then
  : ${SERVER_KEY_PWD_FILE:=/run/secrets/server_key.pwd}
else
  : ${SERVER_KEY_PWD_FILE:=${SERVER_KEY_DIR}/server_key.pwd}
fi

################################################################################

# Default Simple CA user name file location
if [ -e /run/secrets/ca_user.pwd ]; then
  : ${CA_USER_NAME_FILE:=/run/secrets/ca_user.name}
else
  : ${CA_USER_NAME_FILE:=${SERVER_KEY_DIR}/ca_user.name}
fi

# Default Simple CA user password file location
if [ -e /run/secrets/ca_user.pwd ]; then
  : ${CA_USER_PWD_FILE:=/run/secrets/ca_user.pwd}
else
  : ${CA_USER_PWD_FILE:=${SERVER_KEY_DIR}/ca_user.pwd}
fi

################################################################################

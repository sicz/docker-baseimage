ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ENV \
  DOCKER_COMMAND="/bin/bash" \
  CHARSET="UTF-8" \
  LANG="en_US.UTF-8" \
  LC_ALL="en_US.UTF-8"

RUN set -exo pipefail; \
  # Install the packages
  apk add --no-cache \
    bash \
    ca-certificates \
    curl \
    jq \
    libressl \
    nmap-ncat \
    su-exec \
    supervisor \
    tini \
    ; \
  rm -f /etc/supervisord.conf; \
  # Show Alpine Linux version
  cat /etc/alpine-release

COPY rootfs /
RUN set -exo pipefail; \
  chmod +x /docker-entrypoint.sh /etc/supervisor/listener/terminate-container; \
  mkdir -p \
    /etc/ssl/private \
    /run/secrets

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/env", "DOCKER_CONTAINER_START=true", "/docker-entrypoint.sh"]

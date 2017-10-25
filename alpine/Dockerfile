ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG DOCKER_IMAGE_NAME
ARG DOCKER_IMAGE_TAG
ARG DOCKER_PROJECT_DESC
ARG DOCKER_PROJECT_URL
ARG BUILD_DATE
ARG GITHUB_URL
ARG VCS_REF

LABEL \
  org.label-schema.schema-version="1.0" \
  org.label-schema.name="${DOCKER_IMAGE_NAME}" \
  org.label-schema.version="${DOCKER_IMAGE_TAG}" \
  org.label-schema.description="${DOCKER_PROJECT_DESC}" \
  org.label-schema.url="${DOCKER_PROJECT_URL}" \
  org.label-schema.vcs-url="${GITHUB_URL}" \
  org.label-schema.vcs-ref="${VCS_REF}" \
  org.label-schema.build-date="${BUILD_DATE}"

ENV \
  DOCKER_COMMAND="/bin/bash" \
  CHARSET="UTF-8" \
  LANG="en_US.UTF-8" \
  LC_ALL="en_US.UTF-8"

RUN set -exo pipefail; \
  # Upgrade the operating system
  apk upgrade --no-cache; \
  cat /etc/alpine-release; \
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
  rm -f /etc/supervisord.conf

COPY rootfs /
RUN set -exo pipefail; \
  chmod +x /docker-entrypoint.sh; \
  mkdir -p \
    /etc/ssl/private \
    /run/secrets

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/env", "DOCKER_CONTAINER_START=true", "/docker-entrypoint.sh"]

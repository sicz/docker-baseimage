ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG BUILD_DATE
ARG VCS_REF

LABEL \
  org.label-schema.build-date="${BUILD_DATE}" \
  org.label-schema.vcs-ref="${VCS_REF}"

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
    runit \
    su-exec \
    tini \
    ;

ARG DOCKER_IMAGE_NAME
ARG DOCKER_IMAGE_TAG
ARG DOCKER_PROJECT_DESC
ARG DOCKER_PROJECT_URL
ARG GITHUB_URL

LABEL \
  org.label-schema.schema-version="1.0" \
  org.label-schema.name="${DOCKER_IMAGE_NAME}" \
  org.label-schema.version="${DOCKER_IMAGE_TAG}" \
  org.label-schema.description="${DOCKER_PROJECT_DESC}" \
  org.label-schema.url="${DOCKER_PROJECT_URL}" \
  org.label-schema.vcs-url="${GITHUB_URL}"

ARG DOCKER_NAME
ARG DOCKER_VERSION
ARG DOCKER_COMPOSE_VERSION
ARG RUBY_VERSION
ARG GEM_DOCKER_API_VERSION
ARG GEM_RSPEC_VERSION
ARG GEM_SPECINFRA_VERSION
ARG GEM_SERVERSPEC_VERSION

COPY config /
RUN set -exo pipefail; \
  chmod +x /docker-entrypoint.sh; \
  mkdir -p \
    /etc/ssl/certs \
    /etc/ssl/private \
    /run/secrets

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/env", "DOCKER_CONTAINER_START=true", "/docker-entrypoint.sh"]

ENV DOCKER_COMMAND="/bin/bash"
CMD ["${DOCKER_COMMAND}"]

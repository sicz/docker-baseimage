ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date="${BUILD_DATE}"
LABEL org.label-schema.vcs-ref="${VCS_REF}"

RUN set -exo pipefail; \
  # Upgrade system
  apk upgrade --no-cache; \
  cat /etc/alpine-release; \
  # Install base image packages
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

LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.name="${DOCKER_IMAGE_NAME}"
LABEL org.label-schema.version="${DOCKER_IMAGE_TAG}"
LABEL org.label-schema.description="${DOCKER_PROJECT_DESC}"
LABEL org.label-schema.url="${DOCKER_PROJECT_URL}"
LABEL org.label-schema.vcs-url="${GITHUB_URL}"

ARG DOCKER_NAME
ARG DOCKER_VERSION
ARG DOCKER_COMPOSE_VERSION
ARG RUBY_VERSION
ARG GEM_DOCKER_API_VERSION
ARG GEM_RSPEC_VERSION
ARG GEM_SERVERSPEC_VERSION

COPY config /
RUN set -exo pipefail; \
  chmod +x /docker-entrypoint.sh; \
  mkdir -p \
    /etc/ssl/certs \
    /etc/ssl/private \
    /run/secrets \
  ; \
  #
  # Install sicz/dockerspec software
  #
  if [ "${DOCKER_NAME}" = "dockerspec" ]; then \
    # Install packages needed to runn the tests
    apk add --no-cache \
      git \
      make \
      openssh-client \
      python2 \
      ruby=${RUBY_VERSION} \
      ruby-io-console=${RUBY_VERSION} \
      ruby-irb=${RUBY_VERSION} \
      ruby-rdoc=${RUBY_VERSION} \
      ; \
    # Install Docker
    curl -fL "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz" \
     | tar xfz - -C /tmp; \
    mv /tmp/docker/* /usr/bin; \
    rm -rf /tmp/docker; \
    docker --version; \
    # Install Docker Compose
    apk add --no-cache --virtual .build-dependencies \
      py2-pip \
      ; \
    pip install --upgrade pip; \
    pip install docker-compose==${DOCKER_COMPOSE_VERSION}; \
    apk del --no-cache .build-dependencies; \
    docker-compose --version; \
    # Install rspec and serverspec
    gem install \
      docker-api:${GEM_DOCKER_API_VERSION} \
      rspec:${GEM_RSPEC_VERSION} \
      serverspec:${GEM_SERVERSPEC_VERSION} \
      ; \
    gem list --local --quiet \
      docker-api \
      rspec \
      serverspec \
      ; \
    rm -rf /root/.cache /root/.gem; \
  fi

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/env", "DOCKER_CONTAINER_START=true", "/docker-entrypoint.sh"]

ENV DOCKER_COMMAND="/bin/bash"
CMD ["${DOCKER_COMMAND}"]
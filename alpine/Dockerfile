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
    /run/secrets \
  ; \
  #
  # Install sicz/dockerspec software
  #
  if [ "${DOCKER_NAME}" = "dockerspec" ]; then \
    # Install the packages
    apk add --no-cache \
      git \
      make \
      openssh-client \
      python2 \
      "ruby>${RUBY_VERSION}" \
      "ruby-io-console>${RUBY_VERSION}" \
      "ruby-irb>${RUBY_VERSION}" \
      "ruby-rdoc>${RUBY_VERSION}" \
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
      specinfra:${GEM_SPECINFRA_VERSION} \
      serverspec:${GEM_SERVERSPEC_VERSION} \
      ; \
    gem list --local --quiet \
      docker-api \
      rspec \
      specinfra \
      serverspec \
      ; \
    rm -rf /root/.cache /root/.gem; \
    curl -o /usr/lib/ruby/gems/2.4.0/gems/specinfra-2.71.0/lib/specinfra/command/alpine/base/package.rb \
      "https://raw.githubusercontent.com/prehor/specinfra/fix/alpine_is_installed/lib/specinfra/command/alpine/base/package.rb"; \
  fi

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/env", "DOCKER_CONTAINER_START=true", "/docker-entrypoint.sh"]

ENV DOCKER_COMMAND="/bin/bash"
CMD ["${DOCKER_COMMAND}"]

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

ARG JQ_VERSION
ARG RUNIT_VERSION
ARG SU_EXEC_VERSION
ARG TINI_VERSION

RUN set -exo pipefail; \
  # Update the operating system
  yum update -y; \
  cat /etc/centos-release; \
  # Install the packages
  yum install -y \
      bind-utils \
      less \
      net-tools \
      nmap-ncat \
      openssl \
      which \
      ; \
  # Install jq
  curl -fL -o /usr/bin/jq https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64; \
  chmod +x /usr//bin/jq; \
  strip /usr//bin/jq; \
  # Install tini
  curl -fL -o /sbin/tini https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini; \
  chmod +x /sbin/tini; \
  # Install the development dependencies
  yum history new || yum history new; \
  yum install -y \
      gcc \
      glibc-static \
      make \
      ; \
  # Install runit
  mkdir /package; \
  cd /package; \
  curl http://smarden.org/runit/runit-${RUNIT_VERSION}.tar.gz | tar xzf -; \
  cd admin/runit-${RUNIT_VERSION}; \
  package/compile; \
  package/check; \
  mv command/* /sbin; \
  mkdir -p /etc/service; \
  cd /; \
  rm -rf /package; \
  # Install su-exec
  curl -fL https://github.com/ncopa/su-exec/archive/v${SU_EXEC_VERSION}.tar.gz \
    | tar xfz - -C /tmp; \
  cd /tmp/su-exec-${SU_EXEC_VERSION}; \
  make; \
  strip su-exec; \
  mv su-exec /sbin; \
  cd ..; \
  rm -rf su-exec-${SU_EXEC_VERSION}; \
  cd /; \
  # Uninstall the development dependencies
  yum history -y undo 1; \
  # Cleanup yum
  yum clean all

COPY config /
RUN set -exo pipefail; \
  chmod +x /docker-entrypoint.sh; \
  ln -s /etc/pki/tls/private /etc/ssl/private; \
  mkdir -p /run/secrets

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/env", "DOCKER_CONTAINER_START=true", "/docker-entrypoint.sh"]

ENV DOCKER_COMMAND="/bin/bash"
CMD ["${DOCKER_COMMAND}"]

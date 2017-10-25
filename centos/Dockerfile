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

ARG RUNIT_VERSION
ARG SU_EXEC_VERSION
ARG TINI_VERSION

RUN set -exo pipefail; \
  # Update the operating system
  yum update -y; \
  cat /etc/centos-release; \
  # Install the packages
  yum install -y \
    epel-release; \
  yum install -y \
    bind-utils \
    iproute \
    jq \
    less \
    net-tools \
    # nmap-ncat \
    openssl \
    supervisor \
    which \
    ; \
  rm -rf /etc/supervisor/*; \
  # Install the development dependencies
  yum history new; \
  yum install -y \
    gcc \
    glibc-static \
    make \
    ; \
  # CentOS 7 contains ncat an obsoleted version of ncat,
  # docker-entrypoint.d/02-wait-for.sh requires the ncat version 7.x
  rpm -vhU https://nmap.org/dist/ncat-7.40-1.x86_64.rpm; \
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
  # Install tini
  curl -fL -o /sbin/tini https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini; \
  chmod +x /sbin/tini; \
  # Uninstall the development dependencies
  yum history -y undo 1; \
  # Cleanup yum
  yum clean all; \
  rm -rf /var/cache/yum/*

COPY rootfs /
RUN set -exo pipefail; \
  chmod +x /docker-entrypoint.sh; \
  ln -s /etc/pki/tls/private /etc/ssl/private; \
  mkdir -p /run/secrets

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/env", "DOCKER_CONTAINER_START=true", "/docker-entrypoint.sh"]
CMD ["${DOCKER_COMMAND}"]

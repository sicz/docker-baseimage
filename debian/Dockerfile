ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG DOCKER_LANGUAGE="en_US"
ARG DOCKER_CHARSET="UTF-8"
ARG DOCKER_LOCALE="${DOCKER_LANGUAGE}.${DOCKER_CHARSET}"

RUN set -ex; \
  # Get APT cache
  export DEBIAN_FRONTEND="noninteractive"; \
  apt-get update; \
  # Install packages
  apt-get install -y \
    locales \
    ; \
  # Clean APT cache
  rm -rf /var/lib/apt/lists/*; \
  # Set locale
  echo "${DOCKER_LOCALE} ${DOCKER_CHARSET}" > /etc/locale.gen; \
  locale-gen "${DOCKER_LOCALE}"; \
  dpkg-reconfigure locales; \
  update-locale "${DOCKER_LOCALE}"; \
  locale -a; \
  # Use /bin/bash instead of /bin/dash as a shell
  rm -f /bin/sh; \
  ln -s /bin/bash /bin/sh

ENV \
  DEBIAN_FRONTEND="noninteractive" \
  DOCKER_COMMAND="/bin/bash" \
  CHARSET="${DOCKER_CHARSET}" \
  LANG="${DOCKER_LOCALE}" \
  LC_ALL="${DOCKER_LOCALE}"

ARG SU_EXEC_VERSION
ARG TINI_VERSION

RUN set -exo pipefail; \
  # Install packages
  apt update; \
  apt install -y --no-install-recommends \
    ca-certificates \
    curl \
    # iproute \
    jq \
    less \
    net-tools \
    nmap \
    openssl \
    procps \
    supervisor \
    ; \
  rm -rf /etc/supervisord.conf /etc/supervisord.d; \
  # Install development dependencies
  apt install -y \
      gcc \
      make \
      ; \
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
  curl -LO https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}-amd64.deb; \
  apt install -y ./tini_${TINI_VERSION}-amd64.deb; \
  rm -f tini_${TINI_VERSION}-amd64.deb; \
  # Uninstall development dependencies
  apt remove -y \
    gcc \
    make \
    ; \
  apt autoremove -y; \
  # Clean APT cache
  rm -rf /var/lib/apt/lists/*; \
  # Show Debian version
  . /etc/os-release; \
  ln -s /etc/debian_version /etc/debian-release; \
  cat /etc/debian-release

COPY rootfs /
RUN set -exo pipefail; \
  chmod +x /docker-entrypoint.sh /etc/supervisor/listener/terminate-container; \
  mkdir -p /run/secrets

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/bin/env", "DOCKER_CONTAINER_START=true", "/docker-entrypoint.sh"]

# docker-baseimage

[![CircleCI Status Badge](https://circleci.com/gh/sicz/docker-baseimage.svg?style=shield&circle-token=TODO)](https://circleci.com/gh/sicz/docker-baseimage)

**This project is not aimed at public consumption.
It exists to serve as a single endpoint for SICZ containers.**

Docker base images modified for Docker-friendliness.

## Contents

### Alpine Linux based images

This image only contains essential components:
* Official [Alpine Linux image](https://store.docker.com/images/alpine) as a base system
* Modular Docker entrypoint
* `bash` as a shell
* `ca-certificates` contains common CA certificates
* `curl` for transferring data using various protocols
* `jq` for JSON parsing
* `libressl` for PKI and TLS
* `runit` for services supervision and management
* `su_exec` for process impersonation
* `tini` as init process

### CentOS based images

This image only contains essential components:
* Official [CentOS image](https://store.docker.com/images/centos) as a base system
* Modular Docker entrypoint
* `bash` as a shell
* `ca-certificates` contains common CA certificates
* `curl` for transferring data using various protocols
* `jq` for JSON parsing
* `openssl` for PKI and TLS
* `runit` for services supervision and management
* `su_exec` for process impersonation
* `tini` as init process

### DockerSpec images

This image contains tools for testing Docker images:
* [Alpine Linux based image](#Alpine Linux based images)
* [Docker](https://docs.docker.com/engine/) provides Docker command line tools and engine
* [Docker Compose](https://docs.docker.com/compose/) provides Docker command line tools
* [RSpec](http://rspec.info) provides Ruby testing framework
* [ServerSpec](http://serverspec.org) provides server testing framework for RSpec
* [Docker API](https://github.com/swipely/docker-api) provides interface for Docker Remote API for ServerSpec
<!--
* [DockerSpec](https://github.com/zuazo/dockerspec) provides Docker plugin for ServerSpec
-->
## Getting started

These instructions will get you a copy of the project up and running on your
local machine for development and testing purposes. See [Deployment](#deployment)
for notes on how to deploy the project on a live system.

### Installing

Clone GitHub repository to your working directory:
```bash
git clone https://github.com/sicz/docker-baseimage
```

### Usage

Directories with Docker image variants:
|Directory|Docker image|
|---------|------------|
|`alpine`|Alpine Linux latest release|
|`alpine/devel`|Alpine Linux edge branch|
|`centos`|CentOS latest branch|
|`centos/devel`|Currently CentOS latest branch|
|`dockerspec`|DockerSpec based on Alpine Linux latest release|
|`dockerspec/devel`|DockerSpec based on Alpine Linux edge branch|

Use command `make` in project directory:
```bash
make all        # Build and test all Docker images
make build      # Build all Docker images
make rebuild    # Rebuild all Docker images
make test       # Test all Docker images
make clean      # Destroy all running containers and clean working files
make docker-pull              # Pull all images from Docker Registry
make docker-pull-dependencies # Pull all image dependencies from Docker Registry
make docker-pull-images       # Pull all project images from Docker Registry
```

Use command `make` to simplify Docker container development tasks in
directories with Docker image variants:
```bash
make all        # Destroy running containers, build new image and run tests
make default-config # Switch to default configuration environment
make secrets-config # Switch to configuration environment with Docker Swarm like secrets
make custom-config  # Switch to heavily customized configuration environment
make config     # Display `docker-compose` configuration for current configuration environment
make info       # Display `make` variables for current configuration environment
make build      # Build new image
make rebuild    # Build new image without caching
make deploy     # Run containers
make stop       # Stop running containers
make start      # Start stopped containers
make restart    # Restart containers
make destroy    # Destroy running containers
make logs       # Show containers logs
make logs-tail  # Follow containers logs
make shell      # Open shell in running container
make test       # Run tests in current configuration environment
make test-all   # Run tests in all configuration environments
make clean      # Destroy running container and clean working files
make docker-pull              # Pull all images from Docker Registry
make docker-pull-dependencies # Pull project images dependencies from Docker Registry
make docker-pull-images       # Pull project images from Docker Registry
```

## Deployment

This images are intended to serve as a base for other images.

### Alpine Linux base image

You can start with this sample `Dockerfile`:
```Dockerfile
FROM sicz/baseimage-alpine
ENV DOCKER_COMMAND=MY_COMMAND
ENV DOCKER_USER=MY_USER
# Create an user account
RUN set -ex && adduser -D -H -u 1000 ${DOCKER_USER}
# Install some packages
RUN set -ex && apk add --no-cache SOME PACKAGES
# Copy your own entrypoint scripts
COPY dockerfile-entrypoint.d /dockerfile-entrypoint.d
CMD ["${DOCKER_COMMAND}"]
```

### CentOS base image

You can start with this sample `Dockerfile`:
```Dockerfile
FROM sicz/baseimage-centos
ENV DOCKER_COMMAND=MY_COMMAND
ENV DOCKER_USER=MY_USER
# Create an user account
RUN set -ex && adduser -M -U -u 1000 ${DOCKER_USER}
# Install some packages
RUN set -ex && yum install -y SOME PACKAGES && yum clean all
# Copy your own entrypoint scripts
COPY dockerfile-entrypoint.d /dockerfile-entrypoint.d
CMD ["${DOCKER_COMMAND}"]
```

### Multiple services in one container

In case you need to run multiple services within one container, you can use the
`runit`. In short, to create a service create /etc/service/<SERVICE>/run scripts
which at the end execs into the service executable you want to run (and supervise
to keep them running).

Example `services/<SERVICE>/run`:
```bash
#!/bin/bash
# Do some usefull stuff here
exec <SERVICE_BINARY>
```

Example `Dockerfile`
```Dockerfile
FROM sicz/baseimage-alpine
# Do some usefull stuff here
COPY services /etc/services
RUN find /etc/services -type f -exec chmod +x
ENV DOCKER_COMMAND="/sbin/runsvcdir"
CMD ["${DOCKER_COMMAND}"]
```

## Authors

* [Petr Řehoř](https://github.com/prehor) - Initial work.

See also the list of
[contributors](https://github.com/sicz/docker-baseimage-alpine/contributors)
who participated in this project.

## License

This project is licensed under the Apache License, Version 2.0 - see the
[LICENSE](LICENSE) file for details.

## Acknowledgments

This project is inspired by
[baseimage-docker](https://hub.docker.com/r/phusion/baseimage/).

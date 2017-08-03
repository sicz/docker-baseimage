# docker-baseimage

[![CircleCI Status Badge](https://circleci.com/gh/sicz/docker-baseimage.svg?style=shield&circle-token=TODO)](https://circleci.com/gh/sicz/docker-baseimage)

**This project is not aimed at public consumption.
It exists to serve as a single endpoint for SICZ containers.**

Docker base images modified for Docker-friendliness.

## Contents

### Alpine Linux based images

This container only contains essential components:
* Official [Alpine Linux image](https://store.docker.com/images/alpine) as base system
* Modular Docker entrypoint
* `bash` as shell
* `ca-certificates` contains common CA certificates
* `curl` for transferring data using various protocols
* `jq` for JSON parsing
* `libressl` for PKI and TLS
* `runit` for service supervision and management
* `su_exec` for process impersonation
* `tini` as init process

### CentOS based images

This container only contains essential components:
* Official [CentOS image](https://store.docker.com/images/centos) as base system
* Modular Docker entrypoint
* `bash` as shell
* `ca-certificates` contains common CA certificates
* `curl` for transferring data using various protocols
* `jq` for JSON parsing
* `openssl` for PKI and TLS
* `runit` for service supervision and management
* `su_exec` for process impersonation
* `tini` as init process

## Getting started

These instructions will get you a copy of the project up and running on your
local machine for development and testing purposes. See deployment for notes
on how to deploy the project on a live system.

### Installing

Clone GitHub repository to your working directory:
```bash
git clone https://github.com/sicz/docker-baseimage
```

### Usage

Use command `make` to simplify Docker container development tasks:
```bash
make all        # Destroy running container, build new image and run tests
make build      # Build new image
make rebuild    # Build new image without caching
make run        # Run container
make stop       # Stop running container
make start      # Start stopped container
make restart    # Restart container
make status     # Show container status
make logs       # Show container logs
make logs-tail  # Connect to container logs
make shell      # Open shell in running container
make test       # Run tests
make rm         # Destroy running container
make clean      # Destroy running container and clean working files
```

Directories with Docker image variants:
* `.` - Alpine Linux latest release
* `devel` - Alpine Linux edge branch
* `centos` - CentOS latest branch
* `centos/devel` - currently CentOS latest branch

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

## Authors

* [Petr Řehoř](https://github.com/prehor) - Initial work.

See also the list of
[contributors](https://github.com/sicz/docker-baseimage-alpine/contributors)
who participated in this project.

## License

This project is licensed under the Apache License, Version 2.0 - see the
[LICENSE](LICENSE) file for details.

## Acknowledgments

This Docker base images are inspired by
[baseimage-docker](https://hub.docker.com/r/phusion/baseimage/).

# docker-baseimage

[![CircleCI Status Badge](https://circleci.com/gh/sicz/docker-baseimage.svg?style=shield&circle-token=99591a26383b3ac04a207694c1625d819e53d301)](https://circleci.com/gh/sicz/docker-baseimage)

**This project is not aimed at public consumption.
It exists to serve as a single endpoint for SICZ containers.**

Docker base images modified for Docker-friendliness.

## Contents

### Alpine Linux based image

This image only contains essential components:
* Official [Alpine Linux image](https://hub.docker.com/_/alpine/) as a base system
* Modular Docker entrypoint
* `bash` as a shell
* `ca-certificates` contains common CA certificates
* `curl` for data transfers using various protocols
* `jq` for JSON parsing
* `libressl` for PKI and TLS
* `ncat` for bulk data transfers using various protocols
* `supervisord` for services supervision and management
* `su_exec` for process impersonation
* `tini` as an init process

### CentOS based image

This image only contains essential components:
* Official [CentOS image](https://hub.docker.com/_/centos/) as a base system
* Modular Docker entrypoint
* `bash` as a shell
* `ca-certificates` contains common CA certificates
* `curl` for transferring data using various protocols
* `jq` for JSON parsing
* `openssl` for PKI and TLS
* `ncat` for bulk data transfers using various protocols
* `supervisord` for services supervision and management
* `su_exec` for process impersonation
* `tini` as an init process

### Debian based image

This image only contains essential components:
* Official [Debian image](https://hub.docker.com/_/debian/) as a base system
* Modular Docker entrypoint
* `bash` as a shell
* `ca-certificates` contains common CA certificates
* `curl` for transferring data using various protocols
* `jq` for JSON parsing
* `openssl` for PKI and TLS
* `ncat` for bulk data transfers using various protocols
* `supervisord` for services supervision and management
* `su_exec` for process impersonation
* `tini` as an init process

## Getting started

These instructions will get you a copy of the project up and running on your
local machine for development and testing purposes. See [Deployment](#deployment)
for notes on how to deploy the project on a live system.

### Installing

Clone the GitHub repository into your working directory:
```bash
git clone https://github.com/sicz/docker-baseimage
```

### Usage

The project contains Docker image variant directories:
* `alpine` - Alpine Linux base images
* `centos` - CentOS base images
* `debian` - Debian base images

Use the command `make` in the project directory and image variant directories:
```bash
make all                      # Build and test all Docker images
make build                    # Build all Docker images
make rebuild                  # Rebuild all Docker images
make clean                    # Remove all containers and clean work files
make docker-pull              # Pull all images from Docker Registry
make docker-pull-baseimage    # Pull the base image from the Docker Registry
make docker-pull-dependencies # Pull all image dependencies from Docker Registry
make docker-pull-image        # Pull all project images from Docker Registry
make docker-pull-testimage    # Pull all project images from Docker Registry
make docker-push              # Push all project images to Docker Registry
```

Use the command `make` in the image version directories:
```bash
make all                      # Build a new image and run tests for current configuration
make ci                       # Build a new image and run tests for all configurations
make build                    # Build a new image
make rebuild                  # Build a new image without using the Docker layer caching
make default-config           # Switch to the default configuration
make secrets-config           # Switch to the configuration with Docker Swarm like secrets
make custom-config            # Switch to the heavily customized configuration
make config                   # Display the name of the current configuration
make config-file              # Display the configuration file for the current configuration
make vars                     # Display the make variables for the current configuration
make up                       # Remove the containers and then run them fresh
make create                   # Create the containers
make start                    # Start the containers
make stop                     # Stop the containers
make restart                  # Restart the containers
make rm                       # Remove the containers
make wait                     # Wait for the start of the containers
make ps                       # Display running containers
make logs                     # Display the container logs
make logs-tail                # Follow the container logs
make shell                    # Run the shell in the container
make test                     # Run the current configuration tests
make test-all                 # Run tests for all configurations
make test-shell               # Run the shell in the test container
make secrets                  # Create the Simple CA secrets
make clean                    # Remove all containers and work files
make docker-pull              # Pull all images from the Docker Registry
make docker-pull-baseimage    # Pull the base image from the Docker Registry
make docker-pull-dependencies # Pull the project image dependencies from the Docker Registry
make docker-pull-image        # Pull the project image from the Docker Registry
make docker-pull-testimage    # Pull the test image from the Docker Registry
make docker-push              # Push the project image into the Docker Registry
```

## Deployment

Alpine Linux and CentOS images are intended to serve as a base for other images.

### Alpine Linux base image

You can start with this sample `Dockerfile` file:
```Dockerfile
FROM sicz/baseimage-alpine
ENV DOCKER_COMMAND=MY_COMMAND
ENV DOCKER_USER=MY_USER
# Create an user account
RUN adduser -D -H -u 1000 ${DOCKER_USER}
# Install some packages
RUN apk add --no-cache SOME_PACKAGES
# Copy your own entrypoint scripts
COPY dockerfile-entrypoint.d /dockerfile-entrypoint.d
```

### CentOS base image

You can start with this sample `Dockerfile` file:
```Dockerfile
FROM sicz/baseimage-centos
ENV DOCKER_COMMAND=MY_COMMAND
ENV DOCKER_USER=MY_USER
# Create an user account
RUN adduser -M -U -u 1000 ${DOCKER_USER}
# Install some packages
RUN yum install -y SOME_PACKAGES && yum clean all
# Copy your own entrypoint scripts
COPY dockerfile-entrypoint.d /dockerfile-entrypoint.d
```

### Debian base image

You can start with this sample `Dockerfile` file:
```Dockerfile
FROM sicz/baseimage-debian
ENV DOCKER_COMMAND=MY_COMMAND
ENV DOCKER_USER=MY_USER
# Create an user account
RUN adduser --no-create-home --uid ${DOCKER_USER}
# Install some packages
RUN apt update && apt install -y SOME_PACKAGES && rm -rf /var/lib/apt/lists/*
# Copy your own entrypoint scripts
COPY dockerfile-entrypoint.d /dockerfile-entrypoint.d
```

### Multiple services in one container

In case you need to run multiple services within one container, you can use the
`supervisord`. In short, to create a service create /etc/supervisor/<SERVICE>.ini
script which at the end execs into the service executable you want to run (and
supervise to keep them running).

Example `supervisor/<SERVICE>.ini`:
```bash
[program:<SERVICE>]
process_name = <SERVICE>
command = <SERVICE_BINARY>
# Some useful config here
# ...
```

Example `Dockerfile`
```Dockerfile
FROM sicz/baseimage-alpine
# Do some useful stuff here
COPY supervisor /etc/supervisor
ENV DOCKER_COMMAND="/usr/bin/supervisord"
CMD ["--nodaemon", "--configuration", "/etc/supervisor/supervisord.ini"]
```

## Authors

* [Petr Řehoř](https://github.com/prehor) - Initial work.

See also the list of
[contributors](https://github.com/sicz/docker-baseimage/contributors)
who participated in this project.

## License

This project is licensed under the Apache License, Version 2.0 - see the
[LICENSE](LICENSE) file for details.

## Acknowledgments

This project was inspired by
[baseimage-docker](https://github.com/phusion/baseimage-docker).

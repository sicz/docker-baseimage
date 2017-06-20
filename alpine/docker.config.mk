################################################################################

BASEIMAGE_NAME		= alpine

DOCKER_NAME		= $(DOCKER_NAME_PREFIX)-$(BASEIMAGE_NAME)
DOCKER_DESCRIPTION	= Alpine Linux based image modified for Docker-friendliness
DOCKER_PROJECT_URL	= https://alpinelinux.org
DOCKER_FILE		= Dockerfile.$(BASEIMAGE_NAME)

################################################################################

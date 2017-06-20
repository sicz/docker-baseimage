################################################################################

DOCKER_VARIANT		= alpine
DOCKER_NAME		= $(DOCKER_NAME_PREFIX)-$(DOCKER_VARIANT)
DOCKER_DESCRIPTION	= Alpine Linux based image modified for Docker-friendliness
DOCKER_PROJECT_URL	= https://alpinelinux.org
DOCKER_FILE		= Dockerfile.$(DOCKER_VARIANT)

BASEIMAGE_NAME		= $(DOCKER_VARIANT)

################################################################################

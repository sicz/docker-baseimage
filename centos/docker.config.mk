################################################################################

DOCKER_VARIANT		= centos
DOCKER_NAME		= $(DOCKER_NAME_PREFIX)-$(DOCKER_VARIANT)
DOCKER_DESCRIPTION	= CentOS based image modified for Docker-friendliness.
DOCKER_PROJECT_URL	= https://centos.org
DOCKER_FILE		= Dockerfile.$(DOCKER_VARIANT)

BASEIMAGE_NAME		= $(DOCKER_VARIANT)

################################################################################

JQ_VERSION		= 1.5
RUNIT_VERSION		= 2.1.2
SU_EXEC_VERSION		= 0.2
TINI_VERSION		= 0.14.0

DOCKER_BUILD_VARS	+= JQ_VERSION \
			   RUNIT_VERSION \
			   SU_EXEC_VERSION \
			   TINI_VERSION

################################################################################

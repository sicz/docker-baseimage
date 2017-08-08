################################################################################

BASEIMAGE_TAG		?= edge
BASEIMAGE_OS_VERSION	?= 3

################################################################################

DOCKER_TAGS		?=

################################################################################

# Docker Compose file version:
# - docker: 3.3
# - docker-compose: 3.3
# DOCKER_VERSION		?= 17.06.0-ce
# DOCKER_COMPOSE_VERSION	?= 1.15.0
#
RUBY_VERSION		?= 2.4.1-r4
#
# GEM_DOCKER_API_VERSION	?= 1.33.6
# GEM_RSPEC_VERSION		?= 3.6.0
# GEM_SERVERSPEC_VERSION	?= 2.39.1

# If configuration variables are not defined, it is assumed that the development
# image is the same as the production image
DOCKER_IMAGE_CONF	?= $(BASEIMAGE_TAG) \
			   $(DOCKER_VERSION) \
			   $(DOCKER_COMPOSE_VERSION) \
			   $(RUBY_VERSION) \
			   $(GEM_DOCKER_API_VERSION) \
			   $(GEM_RSPEC_VERSION) \
			   $(GEM_SERVERSPEC_VERSION)

ifeq ($(strip $(DOCKER_IMAGE_CONF)),)
DOCKER_BUILD_TARGET	?= docker-tag
DOCKER_REBUILD_TARGET	?= docker-tag
endif

################################################################################

DOCKER_HOME_DIR		?= ../..
include ../Makefile

################################################################################

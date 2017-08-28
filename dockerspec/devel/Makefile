### BASE_IMAGE #################################################################

# BASE_IMAGE_TAG	?= edge
# BASE_IMAGE_OS_VERSION	?= 3

### DOCKER_IMAGE ###############################################################

DOCKER_IMAGE_TAGS	?=

### BUILD ######################################################################

# Docker Compose file version:
# - docker: 3.3
# - docker-compose: 3.3
# DOCKER_VERSION		?= 17.06.1-ce
# DOCKER_COMPOSE_VERSION	?= 1.15.0
#
# RUBY_VERSION			?= 2.4.1-r3
#
# GEM_DOCKER_API_VERSION	?= 1.33.6
# GEM_RSPEC_VERSION		?= 3.6.0
# GEM_SPECINFRA_VERSION		?= 2.71.0
# GEM_SERVERSPEC_VERSION	?= 2.40.0

# If the image configuration variables are not defined, the development image is
# assumed to be the same as the production image
DOCKER_IMAGE_CONF	?= $(BASE_IMAGE_TAG) \
			   $(DOCKER_VERSION) \
			   $(DOCKER_COMPOSE_VERSION) \
			   $(RUBY_VERSION) \
			   $(GEM_DOCKER_API_VERSION) \
			   $(GEM_RSPEC_VERSION) \
			   $(GEM_SPECINFRA_VERSION) \
			   $(GEM_SERVERSPEC_VERSION)

ifeq ($(strip $(DOCKER_IMAGE_CONF)),)
DOCKER_BUILD_TARGET	?= docker-tag
DOCKER_REBUILD_TARGET	?= docker-tag
endif

### MK_DOCKER_IMAGE ############################################################

PROJECT_DIR		?= $(abspath ../..)
include ../Makefile

################################################################################

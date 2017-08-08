################################################################################

BASEIMAGE_TAG		?= edge
BASEIMAGE_OS_VERSION	?= 3

################################################################################

DOCKER_TAGS		?=

################################################################################

# If configuration variables are not defined, it is assumed that the development
# image is the same as the production image
DOCKER_IMAGE_CONF	?= $(BASEIMAGE_TAG)

ifeq ($(strip $(DOCKER_IMAGE_CONF)),)
DOCKER_BUILD_TARGET	?= docker-tag
DOCKER_REBUILD_TARGET	?= docker-tag
endif

################################################################################

DOCKER_HOME_DIR		?= ..
include ../Makefile

################################################################################

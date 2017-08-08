################################################################################

# BASEIMAGE_TAG		?= 7
# DOCKER_TAG		?= 7
DOCKER_TAGS		?=

################################################################################

# JQ_VERSION		?= "1.5"
# RUNIT_VERSION		?= "2.1.2"
# SU_EXEC_VERSION	?= "0.2"
# TINI_VERSION		?= "0.14.0"

# If configuration variables are not defined, it is assumed that the development
# image is the same as the production image
DOCKER_IMAGE_CONF	?= $(BASEIMAGE_TAG) \
			   $(JQ_VERSION) \
			   $(RUNIT_VERSION) \
			   $(SU_EXEC_VERSION) \
			   $(TINI_VERSION)

ifeq ($(strip $(DOCKER_IMAGE_CONF)),)
DOCKER_BUILD_TARGET	?= docker-tag
DOCKER_REBUILD_TARGET	?= docker-tag
endif

################################################################################

DOCKER_HOME_DIR		?= ../..
include ../Makefile

################################################################################

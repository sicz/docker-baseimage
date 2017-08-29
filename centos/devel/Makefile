### BASE_IMAGE #################################################################

# BASE_IMAGE_TAG	?= 7

### DOCKER_IMAGE ###############################################################

# DOCKER_IMAGE_TAG	?= 7
DOCKER_IMAGE_TAGS	?=

### BUILD ######################################################################

# Docker image build variables
# JQ_VERSION		?= "1.5"
# RUNIT_VERSION		?= "2.1.2"
# SU_EXEC_VERSION	?= "0.2"
# TINI_VERSION		?= "0.14.0"

# If the image configuration variables are not defined, the development image is
# assumed to be the same as the latest image
BUILD_CONFIG		?= $(BASE_IMAGE_TAG) \
			   $(JQ_VERSION) \
			   $(RUNIT_VERSION) \
			   $(SU_EXEC_VERSION) \
			   $(TINI_VERSION)

ifeq ($(strip $(BUILD_CONFIG)),)
DOCKER_CI_TARGET	?= docker-tag
DOCKER_BUILD_TARGET	?= docker-tag
DOCKER_REBUILD_TARGET	?= docker-tag
endif

### MK_DOCKER_IMAGE ############################################################

PROJECT_DIR		?= $(abspath ../..)
include ../Makefile

################################################################################

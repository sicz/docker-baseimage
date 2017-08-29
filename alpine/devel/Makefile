### BASE_IMAGE #################################################################

# BASE_IMAGE_OS_VERSION	?= 3
# BASE_IMAGE_TAG	?= edge

### DOCKER_IMAGE ###############################################################

DOCKER_IMAGE_TAGS	?=

### BUILD ######################################################################

# If the image configuration variables are not defined, the development image is
# assumed to be the same as the latest image
BUILD_CONFIG		?= $(BASE_IMAGE_TAG)

ifeq ($(strip $(BUILD_CONFIG)),)
DOCKER_CI_TARGET	?= docker-tag
DOCKER_BUILD_TARGET	?= docker-tag
DOCKER_REBUILD_TARGET	?= docker-tag
endif

### MK_DOCKER_IMAGE ############################################################

PROJECT_DIR		?= $(abspath ../..)
include ../Makefile

################################################################################

### BASE_IMAGE #################################################################

BASE_IMAGE_NAME		?= alpine
BASE_IMAGE_TAG		?= $(BASE_IMAGE_OS_VERSION)

BASE_IMAGE_OS_NAME	?= Alpine Linux
BASE_IMAGE_OS_VERSION	?= 3.6
BASE_IMAGE_OS_URL	?= https://alpinelinux.org

### DOCKER_IMAGE ###############################################################

DOCKER_IMAGE_TAGS	?= latest

### DOCKER_VERSIONS ###########################################################

DOCKER_VERSIONS		?= latest devel

### MK_DOCKER_IMAGE ############################################################

PROJECT_DIR		?= $(abspath ..)
include $(PROJECT_DIR)/docker.version.mk

################################################################################

### BASE_IMAGE #################################################################

BASE_IMAGE_NAME		?= centos
BASE_IMAGE_TAG		?= $(BASE_IMAGE_OS_VERSION)

BASE_IMAGE_OS_FAMILY	?= redhat
BASE_IMAGE_OS_NAME	?= CentOS
BASE_IMAGE_OS_VERSION	?= 7
BASE_IMAGE_OS_URL	?= https://centos.org

### DOCKER_IMAGE ###############################################################

DOCKER_IMAGE_TAGS	?= latest

### DOCKER_VERSIONS ############################################################

DOCKER_VERSIONS		?= latest devel

### BUILD #######################################################################

# Docker image build variables
BUILD_VARS		+= JQ_VERSION \
			   RUNIT_VERSION \
			   SU_EXEC_VERSION \
			   TINI_VERSION

JQ_VERSION		?= "1.5"
RUNIT_VERSION		?= "2.1.2"
SU_EXEC_VERSION		?= "0.2"
TINI_VERSION		?= "0.14.0"

### MK_DOCKER_IMAGE ############################################################

PROJECT_DIR		?= $(abspath ..)
include $(PROJECT_DIR)/docker.version.mk

################################################################################

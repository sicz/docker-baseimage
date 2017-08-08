################################################################################

BASEIMAGE_NAME		?= centos
BASEIMAGE_TAG		?= $(BASEIMAGE_OS_VERSION)

BASEIMAGE_OS_NAME	?= CentOS
BASEIMAGE_OS_URL	?= https://centos.org
BASEIMAGE_OS_FAMILY	?= redhat
BASEIMAGE_OS_VERSION	?= 7

################################################################################

DOCKER_VARIANT_DIR	?= $(DOCKER_HOME_DIR)/$(BASEIMAGE_NAME)

DOCKER_BUILD_VARS	+= JQ_VERSION \
			   RUNIT_VERSION \
			   SU_EXEC_VERSION \
			   TINI_VERSION

################################################################################

JQ_VERSION		?= "1.5"
RUNIT_VERSION		?= "2.1.2"
SU_EXEC_VERSION		?= "0.2"
TINI_VERSION		?= "0.14.0"

################################################################################

DOCKER_HOME_DIR		?= ..
include $(DOCKER_HOME_DIR)/Makefile

################################################################################

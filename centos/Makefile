################################################################################

BASEIMAGE_OS_NAME	= CentOS
BASEIMAGE_OS_URL	= https://centos.org

BASEIMAGE_NAME		= centos
BASEIMAGE_TAG		?= 7.3.1611

################################################################################

DOCKER_TAG		?= 7

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

################################################################################

BASEIMAGE_TAG		?= edge
DOCKER_TAG		?= 3
DOCKER_TAGS		?= edge devel

DOCKER_PUSH_TAGS	?= $(DOCKER_TAGS)
DOCKER_PULL_TAGS	?= $(DOCKER_TAGS)

################################################################################

BUILD_TARGET_HELPER	= remove-docker-tag

################################################################################

DOCKER_HOME_DIR		?= ..
include ../Makefile

################################################################################

.PHONY: remove-docker-tag
remove-docker-tag:
	-@docker image rm $(DOCKER_IMAGE)

################################################################################

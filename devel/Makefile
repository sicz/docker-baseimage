################################################################################

# Alpine Linux edge reports wrong version in tests, we must use numeric
# DOCKER_TAG and remove it after build.

BASEIMAGE_TAG		?= edge
DOCKER_TAG		?= 3
DOCKER_TAGS		?= edge

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

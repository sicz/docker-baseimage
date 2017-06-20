################################################################################

include ../../docker.config.mk
include ../docker.config.mk

################################################################################

DOCKER_HOME_DIR		= ../..
DOCKER_TEST_DIR		= ..

DOCKER_RUN_OPTS		= $(DOCKER_SHELL_OPTS) \
			  -v /var/run/docker.sock:/var/run/docker.sock

################################################################################

.PHONY: all build rebuild deploy run up destroy down rm start stop restart
.PHONY: status logs logs-tail shell test clean

all: destroy build deploy logs test
build: docker-build
rebuild: docker-rebuild
deploy run up: docker-deploy
destroy down rm: docker-destroy
start: docker-start
stop: docker-stop
restart: docker-stop docker-start
status: docker-status
logs: docker-logs
logs-tail: docker-logs-tail
shell: docker-shell
test: docker-test
clean: destroy docker-clean

################################################################################

DOCKER_MK_DIR		?= $(DOCKER_HOME_DIR)/../Mk
include $(DOCKER_MK_DIR)/docker.container.mk

################################################################################

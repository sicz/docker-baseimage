### DOCKER_IMAGE #############################################################

DOCKER_PROJECT		?= sicz
DOCKER_PROJECT_DESC	?= $(BASE_IMAGE_OS_NAME) based image modified for Docker-friendliness
DOCKER_PROJECT_URL	?= $(BASE_IMAGE_OS_URL)

DOCKER_NAME		?= baseimage-$(BASE_IMAGE_NAME)
DOCKER_IMAGE_TAG	?= $(BASE_IMAGE_TAG)
DOCKER_IMAGE_DEPENDENCIES += $(SIMPLE_CA_IMAGE)

### BUILD ######################################################################

# Allows a change of the build/restore targets to the docker-tag if
# the development version is the same as the production version
DOCKER_BUILD_TARGET	?= docker-build
DOCKER_REBUILD_TARGET	?= docker-rebuild

### DOCKER_EXECUTOR ############################################################

# Use Docker Compose executor
DOCKER_EXECUTOR		?= compose

# Use multiple Docker executor configurations
DOCKER_CONFIGS		?= default \
			   secrets \
			   custom

# Docker executor configuration
DOCKER_CONFIG_FILE	?= .docker-executor-config
DOCKER_CONFIG		?= $(shell \
				if [ -e $(DOCKER_CONFIG_FILE) ]; then \
					cat $(DOCKER_CONFIG_FILE); \
				else \
					echo "default"; \
				fi \
			   )

# Use the same service name for all configurations
SERVICE_NAME		?= baseimage

### DEFAULT_CONFIG #############################################################

# Default configuration with Simple CA
COMPOSE_VARS		+= SERVER_P12_FILE \
			   SIMPLE_CA_IMAGE

ifeq ($(DOCKER_CONFIG),default)
SERVER_P12_FILE		?= /etc/ssl/private/server.p12
endif

### SECRETS_CONFIG #############################################################

# Default configuration with Simple CA and Docker Swarm like secrets
ifeq ($(DOCKER_CONFIG),secrets)
COMPOSE_VARS		+= CA_CRT_FILE \
			   CA_USER_NAME_FILE \
			   CA_USER_PWD_FILE \
			   SERVER_KEY_PWD_FILE
CA_CRT_FILE		?= /run/secrets/ca.crt
CA_USER_NAME_FILE	?= /run/secrets/ca_user.name
CA_USER_PWD_FILE	?= /run/secrets/ca_user.pwd
SERVER_KEY_PWD_FILE	?= /run/secrets/server.pwd
SERVER_P12_FILE		?= /etc/ssl/private/server.p12
endif

### CUSTOM_CONFIG ##############################################################

# Custom configuration with Simple CA
ifeq ($(DOCKER_CONFIG),custom)
COMPOSE_VARS		+= CA_CRT_FILE \
			   CA_USER_NAME_FILE \
			   CA_USER_PWD_FILE \
			   SERVER_CRT_SUBJECT \
			   SERVER_CRT_HOST \
			   SERVER_CRT_IP \
			   SERVER_CRT_OID \
			   SERVER_CRT_DIR \
			   SERVER_CRT_FILE \
			   SERVER_KEY_DIR \
			   SERVER_KEY_FILE \
			   SERVER_KEY_PWD_FILE \
			   SERVER_P12_FILE
CA_CRT_FILE		?= /root/ca.pem
CA_USER_NAME_FILE	?= /root/user.name
CA_USER_PWD_FILE	?= /root/user.pwd
SERVER_CRT_SUBJECT	?= CN=baseimage,O=test
SERVER_CRT_HOST		?= baseimage.local
SERVER_CRT_IP		?= 1.2.3.4
SERVER_CRT_OID		?= 1.2.3.4.5.6
SERVER_CRT_DIR		?= /var/lib
SERVER_CRT_FILE		?= /root/crt.pem
SERVER_KEY_DIR		?= /var/lib
SERVER_KEY_FILE		?= /root/key.pem
SERVER_KEY_PWD_FILE	?= /root/key.pwd
SERVER_P12_FILE		?= /root/keystore.p12
endif

### TEST #######################################################################

TEST_VARS		+= BASE_IMAGE_OS_NAME \
			   BASE_IMAGE_OS_FAMILY \
			   BASE_IMAGE_OS_VERSION

### SIMPLE_CA ##################################################################

# Simple CA image
SIMPLE_CA_IMAGE_NAME	?= sicz/simple-ca
SIMPLE_CA_IMAGE_TAG	?= latest
SIMPLE_CA_IMAGE		?= $(SIMPLE_CA_IMAGE_NAME):$(SIMPLE_CA_IMAGE_TAG)

# Simple CA service name in Docker Compose file
SIMPLE_CA_SERVICE_NAME	?= $(shell echo $(SIMPLE_CA_IMAGE_NAME) | sed -E -e "s|^.*/||" -e "s/[^[:alnum:]_]+/_/g")

# Simple CA container name
# Docker container name
ifeq ($(DOCKER_EXECUTOR),container)
SIMPLE_CA_CONTAINER_NAME ?= $(DOCKER_EXECUTOR_ID)_$(SIMPLE_CA_SERVICE_NAME)
else ifeq ($(DOCKER_EXECUTOR),compose)
SIMPLE_CA_CONTAINER_NAME ?= $(DOCKER_EXECUTOR_ID)_$(SIMPLE_CA_SERVICE_NAME)_1
else ifeq ($(DOCKER_EXECUTOR),stack)
# TODO: Docker Swarm Stack executor
SIMPLE_CA_CONTAINER_NAME ?= $(DOCKER_EXECUTOR_ID)_$(SIMPLE_CA_SERVICE_NAME)_1
else
$(error Unknown Docker executor "$(DOCKER_EXECUTOR)")
endif

### MAKE_VARS ##################################################################

MAKE_VARS		?= GITHUB_MAKE_VARS \
			   BASE_IMAGE_OS_MAKE_VARS \
			   BASE_IMAGE_MAKE_VARS \
			   DOCKER_IMAGE_MAKE_VARS \
			   BUILD_MAKE_VARS \
			   BUILD_TARGETS_MAKE_VARS \
			   EXECUTOR_MAKE_VARS \
			   CONFIG_MAKE_VARS \
			   SHELL_MAKE_VARS \
			   DOCKER_REGISTRY_MAKE_VARS \
			   DOCKER_VERSION_MAKE_VARS

# Display make variables
define BASE_IMAGE_OS_MAKE_VARS
BASE_IMAGE_OS_FAMILY:	$(BASE_IMAGE_OS_FAMILY)
BASE_IMAGE_OS_NAME:	$(BASE_IMAGE_OS_NAME)
BASE_IMAGE_OS_VERSION:	$(BASE_IMAGE_OS_VERSION)
BASE_IMAGE_OS_URL:	$(BASE_IMAGE_OS_URL)
endef
export BASE_IMAGE_OS_MAKE_VARS

define BUILD_TARGETS_MAKE_VARS
DOCKER_BUILD_TARGET:	$(DOCKER_BUILD_TARGET)
DOCKER_REBUILD_TARGET:	$(DOCKER_REBUILD_TARGET)
endef
export BUILD_TARGETS_MAKE_VARS

define CONFIG_MAKE_VARS
SIMPLE_CA_IMAGE_NAME:	$(SIMPLE_CA_IMAGE_NAME)
SIMPLE_CA_IMAGE_TAG:	$(SIMPLE_CA_IMAGE_TAG)
SIMPLE_CA_IMAGE:	$(SIMPLE_CA_IMAGE)
SIMPLE_CA_SERVICE_NAME:	$(SIMPLE_CA_SERVICE_NAME)
SIMPLE_CA_CONTAINER_NAME: $(SIMPLE_CA_CONTAINER_NAME)

CA_CRT_FILE:		$(CA_CRT_FILE)
CA_USER_NAME_FILE:	$(CA_USER_NAME_FILE)
CA_USER_PWD_FILE:	$(CA_USER_PWD_FILE)

SERVER_CRT_SUBJECT:	$(SERVER_CRT_SUBJECT)
SERVER_CRT_HOST:	$(SERVER_CRT_HOST)
SERVER_CRT_IP		$(SERVER_CRT_IP)
SERVER_CRT_OID:		$(SERVER_CRT_OID)
SERVER_CRT_DIR:		$(SERVER_CRT_DIR)
SERVER_CRT_FILE:	$(SERVER_CRT_FILE)

SERVER_KEY_DIR:		$(SERVER_KEY_DIR)
SERVER_KEY_FILE:	$(SERVER_KEY_FILE)
SERVER_KEY_PWD_FILE:	$(SERVER_KEY_PWD_FILE)

SERVER_P12_FILE:	$(SERVER_P12_FILE)
endef
export CONFIG_MAKE_VARS

### DOCKER_VERSION_TARGETS #####################################################

DOCKER_ALL_VERSIONS_TARGETS ?= build rebuild ci clean
DOCKER_VARIANT_DIR	?= $(PROJECT_DIR)/$(BASE_IMAGE_NAME)

### MAKE_TARGETS #############################################################

# Build and test image
.PHONY: all ci
all: build up wait logs test
ci: build test-all clean

# Display make variables
.PHONY: makevars vars
makevars vars: display-makevars

### BUILD_TARGETS ##############################################################

# Build Docker image with cached layers
.PHONY: build
build: $(DOCKER_BUILD_TARGET)
	@true

# Build Docker image without cached layers
.PHONY: rebuild
rebuild: $(DOCKER_REBUILD_TARGET)
	@true

### EXECUTOR_TARGETS ###########################################################

# Display Docker executor configuration
.PHONY: config
config: display-executor-config

# Display Docker COmpose/Swarm configuration file
.PHONY: config-file
config-file: display-config-file

# Change containers configuration
.PHONY: $(addsuffix -config,$(DOCKER_CONFIGS))
$(addsuffix -config,$(DOCKER_CONFIGS)): rm
	@set -eo pipefail; \
	$(MAKE) set-executor-config DOCKER_CONFIG=$(shell echo $@ | sed "s/-config//")

# Remove containers and then start fresh ones
.PHONY: run up
run up: docker-up

# Create containers
.PHONY: create
create: display-executor-config secrets docker-create .docker-$(DOCKER_EXECUTOR)-secrets
	@true

.docker-$(DOCKER_EXECUTOR)-secrets:
	@$(ECHO) "Copying secrets to container $(CONTAINER_NAME)"
	@CA_CRT_FILE=$(CA_CRT_FILE); \
	 CA_USER_NAME_FILE=$(CA_USER_NAME_FILE); \
	 CA_USER_PWD_FILE=$(CA_USER_PWD_FILE); \
	 SERVER_KEY_PWD_FILE=$(SERVER_KEY_PWD_FILE); \
	 docker cp secrets/ca.crt	$(CONTAINER_NAME):$${CA_CRT_FILE:-/etc/ssl/certs/ca.crt}; \
	 docker cp secrets/ca_user.name	$(CONTAINER_NAME):$${CA_USER_NAME_FILE:-/etc/ssl/private/ca_user.name}; \
	 docker cp secrets/ca_user.pwd	$(CONTAINER_NAME):$${CA_USER_PWD_FILE:-/etc/ssl/private/ca_user.pwd}; \
	 docker cp secrets/server.pwd 	$(CONTAINER_NAME):$${SERVER_KEY_PWD_FILE:-/etc/ssl/private/server.pwd}
	@$(ECHO) "Copying secrets to container $(SIMPLE_CA_CONTAINER_NAME)"
	@@docker cp secrets $(SIMPLE_CA_CONTAINER_NAME):/var/lib/simple-ca
	@$(ECHO) $(CONTAINER_NAME) > $@

# Start containers
.PHONY: start
start: create docker-start

# Wait to container start
.PHONY: wait
wait: start docker-wait

# List running containers
.PHONY: ps
ps: docker-ps

# Display containers logs
.PHONY: logs
logs: docker-logs

# Follow containers logs
.PHONY: logs-tail tail
logs-tail tail: docker-logs-tail

# Run shell in the container
.PHONY: shell sh
shell sh: start docker-shell

# Run tests for current executor configuration
.PHONY: test
test: start docker-test

# Run tests for all executor configurations
.PHONY: test-all
test-all: rm $(addprefix test-,$(DOCKER_CONFIGS))

.PHONY: $(addprefix test-,$(DOCKER_CONFIGS))
$(addprefix test-,$(DOCKER_CONFIGS)): secrets
	@$(ECHO)
	@$(ECHO)
	@$(ECHO) "===> $(DOCKER_IMAGE) with $(shell echo $@ | sed -E -e "s/^test-//") configuration"
	@$(ECHO)
	@$(ECHO)
	@$(MAKE) $$(echo "$@-config" | sed -E -e "s/^test-//")
	@$(MAKE) start wait logs test rm

# Run shell in test container
.PHONY: test-shell tsh
test-shell tsh:
	@$(MAKE) test TEST_CMD=/bin/bash

# Stop containers
.PHONY: stop
stop: docker-stop

# Restart containers
.PHONY: restart
restart: stop start

# Delete containers
.PHONY: down rm
down rm: docker-rm

# Clean project
.PHONY: clean
clean: docker-clean clean-secrets

### SIMPLE_CA_TARGETS ##########################################################

# Create Simple CA secrets
.PHONY: secrets
secrets: secrets/ca.crt
	@true

secrets/ca.crt:
	@$(ECHO) "Starting container $(SIMPLE_CA_CONTAINER_NAME) with command \"secrets\""
	@docker run --interactive --tty --name=$(SIMPLE_CA_CONTAINER_NAME) $(SIMPLE_CA_IMAGE) secrets
	@$(ECHO) "Copying secrets from container $(SIMPLE_CA_CONTAINER_NAME)"
	@docker cp $(SIMPLE_CA_CONTAINER_NAME):/var/lib/simple-ca/secrets .
	@$(ECHO) "Removing container $(SIMPLE_CA_CONTAINER_NAME)"
	@docker rm --force $(SIMPLE_CA_CONTAINER_NAME) > /dev/null

# Clean Simple CA secrets
.PHONY: clean-secrets
clean-secrets:
	@SECRET_FILES=$$(ls secrets/*.crt secrets/*.key secrets/*.pwd secrets/*.name 2> /dev/null | tr '\n' ' ' || true); \
	 if [ -n "$${SECRET_FILES}" ]; then \
		$(ECHO) "Removing secrets: $${SECRET_FILES}"; \
		chmod u+w $${SECRET_FILES}; \
		rm -f $${SECRET_FILES}; \
	 fi

### MK_DOCKER_IMAGE ############################################################

# Include Docker common targets
MK_DIR			?= $(PROJECT_DIR)/../Mk
include $(MK_DIR)/docker.image.mk

################################################################################

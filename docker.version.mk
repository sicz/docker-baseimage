### DOCKER_IMAGE ###############################################################

DOCKER_PROJECT		?= sicz
DOCKER_PROJECT_DESC	?= $(BASE_IMAGE_OS_NAME) based image modified for Docker-friendliness
DOCKER_PROJECT_URL	?= $(BASE_IMAGE_OS_URL)

DOCKER_NAME		?= baseimage-$(BASE_IMAGE_NAME)
DOCKER_IMAGE_TAG	?= $(BASE_IMAGE_TAG)

### BUILD ######################################################################

VARIANT_DIR		?= $(PROJECT_DIR)/$(BASE_IMAGE_NAME)

### DOCKER_EXECUTOR ############################################################

# Use the Docker Compose executor
DOCKER_EXECUTOR		?= compose

# Use multiple Docker executor configurations
DOCKER_CONFIGS		?= default \
			   secrets \
			   custom

# Get the name of the Docker executor configuration
DOCKER_CONFIG_FILE	?= .docker-executor-config
DOCKER_CONFIG		?= $(shell \
				if [ -e $(DOCKER_CONFIG_FILE) ]; then \
					cat $(DOCKER_CONFIG_FILE); \
				else \
					echo "default"; \
				fi \
			   )

# Use the same service name for all variants
SERVICE_NAME		?= baseimage

### DEFAULT_CONFIG #############################################################

# Default configuration with Simple CA
COMPOSE_VARS		+= SIMPLE_CA_IMAGE

ifeq ($(DOCKER_CONFIG),default)
COMPOSE_VARS		+= SERVER_CRT_HOST \
			   SERVER_KEY_PWD_FILE \
			   SERVER_P12_FILE
TEST_VARS		+= CA_CRT_FILE \
			   CA_USER_NAME_FILE \
			   CA_USER_PWD_FILE
CA_CRT_FILE		?= /etc/ssl/certs/ca.crt
CA_USER_NAME_FILE	?= /etc/ssl/private/ca_user.name
CA_USER_PWD_FILE	?= /etc/ssl/private/ca_user.pwd
SERVER_CRT_HOST		?= $(SERVICE_NAME).local
SERVER_KEY_PWD_FILE	?= /etc/ssl/private/server.pwd
SERVER_P12_FILE		?= /etc/ssl/private/server.p12
endif

### SECRETS_CONFIG #############################################################

# Default configuration with Simple CA and Docker Swarm like secrets
ifeq ($(DOCKER_CONFIG),secrets)
COMPOSE_VARS		+= SERVER_CRT_HOST \
			   SERVER_KEY_PWD_FILE \
			   SERVER_P12_FILE
TEST_VARS		+= CA_CRT_FILE \
			   CA_USER_NAME_FILE \
			   CA_USER_PWD_FILE
CA_CRT_FILE		?= /run/secrets/ca.crt
CA_USER_NAME_FILE	?= /run/secrets/ca_user.name
CA_USER_PWD_FILE	?= /run/secrets/ca_user.pwd
SERVER_CRT_HOST		?= $(SERVICE_NAME).local
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
SERVER_CRT_SUBJECT	?= CN=$(SERVICE_NAME),O=test
SERVER_CRT_HOST		?= $(SERVICE_NAME).local,$(SERVICE_NAME).test
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
			   BASE_IMAGE_OS_VERSION \
			   DOCKER_CONFIG

### SIMPLE_CA ##################################################################

# Docker image dependencies
DOCKER_IMAGE_DEPENDENCIES += $(SIMPLE_CA_IMAGE)

# Simple CA image
SIMPLE_CA_NAME		?= simple-ca
SIMPLE_CA_IMAGE_NAME	?= $(DOCKER_PROJECT)/$(SIMPLE_CA_NAME)
SIMPLE_CA_IMAGE_TAG	?= latest
SIMPLE_CA_IMAGE		?= $(SIMPLE_CA_IMAGE_NAME):$(SIMPLE_CA_IMAGE_TAG)

# Simple CA service name in Docker Compose file
SIMPLE_CA_SERVICE_NAME	?= $(shell echo $(SIMPLE_CA_NAME) | sed -E -e "s/[^[:alnum:]_]+/_/g")

# Simple CA container name
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

# Display the make variables
MAKE_VARS		?= GITHUB_MAKE_VARS \
			   BASE_IMAGE_OS_MAKE_VARS \
			   BASE_IMAGE_MAKE_VARS \
			   DOCKER_IMAGE_MAKE_VARS \
			   BUILD_MAKE_VARS \
			   EXECUTOR_MAKE_VARS \
			   CONFIG_MAKE_VARS \
			   SHELL_MAKE_VARS \
			   DOCKER_REGISTRY_MAKE_VARS

define BASE_IMAGE_OS_MAKE_VARS
BASE_IMAGE_OS_NAME:	$(BASE_IMAGE_OS_NAME)
BASE_IMAGE_OS_VERSION:	$(BASE_IMAGE_OS_VERSION)
BASE_IMAGE_OS_URL:	$(BASE_IMAGE_OS_URL)
endef
export BASE_IMAGE_OS_MAKE_VARS

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

### MAKE_TARGETS #############################################################

# Build a new image and run tests for current configuration
.PHONY: all
all: clean build start wait logs test

# Build a new image and run tests for all configurations
.PHONY: ci
ci: clean build test-all

### BUILD_TARGETS ##############################################################

# Build a new image with using the Docker layer caching
.PHONY: build
build: docker-build

# Build a new image without using the Docker layer caching
.PHONY: rebuild
rebuild: docker-rebuild

### EXECUTOR_TARGETS ###########################################################

# Display the name of the current configuration
.PHONY: config
config: display-executor-config

# Display the configuration file for the current configuration
.PHONY: config-file
config-file: display-config-file

# Display the make variables for the current configuration
.PHONY: makevars vars
makevars vars: display-makevars

# Switch the configuration environment
.PHONY: $(addsuffix -config,$(DOCKER_CONFIGS))
$(addsuffix -config,$(DOCKER_CONFIGS)): clean
	@set -eo pipefail; \
	$(MAKE) set-executor-config DOCKER_CONFIG=$(shell echo $@ | sed "s/-config//")

# Remove the containers and then run them fresh
.PHONY: run up
run up: docker-up

# Create the containers
.PHONY: create
create: display-executor-config docker-create .docker-$(DOCKER_EXECUTOR)-secrets
	@true

.docker-$(DOCKER_EXECUTOR)-secrets: secrets
	@$(ECHO) "Copying secrets to container $(CONTAINER_NAME)"
	@docker cp secrets/ca.crt	$(CONTAINER_NAME):$(CA_CRT_FILE)
	@docker cp secrets/ca_user.name	$(CONTAINER_NAME):$(CA_USER_NAME_FILE)
	@docker cp secrets/ca_user.pwd	$(CONTAINER_NAME):$(CA_USER_PWD_FILE)
	@$(ECHO) $(CONTAINER_NAME) > $@

# Start the containers
.PHONY: start
start: create docker-start

# Wait for the start of the containers
.PHONY: wait
wait: start docker-wait

# Display running containers
.PHONY: ps
ps: docker-ps

# Display the container logs
.PHONY: logs
logs: docker-logs

# Follow the container logs
.PHONY: logs-tail tail
logs-tail tail: docker-logs-tail

# Run the shell in the container
.PHONY: shell sh
shell sh: start docker-shell

# Run the current configuration tests
.PHONY: test
test: start docker-test

# Run tests for all configurations
.PHONY: test-all
test-all: $(addprefix test-,$(DOCKER_CONFIGS))

.PHONY: $(addprefix test-,$(DOCKER_CONFIGS))
$(addprefix test-,$(DOCKER_CONFIGS)):
	@$(ECHO)
	@$(ECHO)
	@$(ECHO) "===> $(DOCKER_IMAGE) with $(shell echo $@ | sed -E -e "s/^test-//") configuration"
	@$(ECHO)
	@$(ECHO)
	@$(MAKE) $$(echo "$@-config" | sed -E -e "s/^test-//")
	@$(MAKE) start wait logs test clean

# Run the shell in the test container
.PHONY: test-shell tsh
test-shell tsh:
	@$(MAKE) test TEST_CMD=/bin/bash

# Stop the containers
.PHONY: stop
stop: docker-stop

# Restart the containers
.PHONY: restart
restart: stop start

# Remove the containers
.PHONY: down rm
down rm: docker-rm

# Remove all containers and work files
.PHONY: clean
clean: docker-clean clean-secrets

### SIMPLE_CA_TARGETS ##########################################################

# Create the Simple CA secrets
.PHONY: secrets
secrets:
	@$(COMPOSE_CMD) up $(COMPOSE_UP_OPTS) $(SIMPLE_CA_SERVICE_NAME)
	@sleep 1
	@$(ECHO) "Copying secrets from container $(SIMPLE_CA_CONTAINER_NAME)"
	@docker cp $(SIMPLE_CA_CONTAINER_NAME):/var/lib/simple-ca/secrets .

# Clean the Simple CA secrets
.PHONY: clean-secrets
clean-secrets:
	@SECRET_FILES=$$(ls secrets/*.crt secrets/*.key secrets/*.pwd secrets/*.name 2> /dev/null | tr '\n' ' ' || true); \
	 if [ -n "$${SECRET_FILES}" ]; then \
		$(ECHO) "Removing secrets: $${SECRET_FILES}"; \
		chmod u+w $${SECRET_FILES}; \
		rm -f $${SECRET_FILES}; \
	 fi
	@if [ -e secrets ]; then \
		$(ECHO) "Removing secrets directory"; \
		rmdir secrets; \
	 fi

### MK_DOCKER_IMAGE ############################################################

MK_DIR			?= $(PROJECT_DIR)/../Mk
include $(MK_DIR)/docker.image.mk

################################################################################

################################################################################

BASEIMAGE_OS_NAME	?= Alpine Linux
BASEIMAGE_OS_URL	?= https://alpinelinux.org
BASEIMAGE_OS_VERSION	?= 3.6

BASEIMAGE_NAME		?= alpine
BASEIMAGE_TAG		?= $(BASEIMAGE_OS_VERSION)

################################################################################

DOCKER_PROJECT		?= sicz
DOCKER_NAME		?= baseimage-$(BASEIMAGE_NAME)
DOCKER_TAG		?= $(BASEIMAGE_TAG)
DOCKER_TAGS		?= latest
DOCKER_DESCRIPTION	?= $(BASEIMAGE_OS_NAME) based image modified for Docker-friendliness
DOCKER_PROJECT_URL	?= $(BASEIMAGE_OS_URL)

DOCKER_RUN_OPTS		+= -v /var/run/docker.sock:/var/run/docker.sock \
			   -e SERVER_P12=/etc/ssl/private/server.p12 \
			   -e SIMPLE_CA_URL=https://simple-ca.local \
			   --link $(DOCKER_SIMPLE_CA_NAME):simple-ca.local \
			   $(DOCKER_SHELL_OPTS)

DOCKER_TEST_VARS	+= BASEIMAGE_OS_VERSION
DOCKER_TEST_OPTS	+= -v $(abspath $(DOCKER_BUILD_DIR))/config:/config

DOCKER_FILE		= Dockerfile.$(BASEIMAGE_NAME)

DOCKER_SUBDIRS		= devel \
			  dockerspec \
			  dockerspec/devel \
			  centos \
			  centos/devel

DOCKER_ALL_TARGETS	+= all build rebuild clean test

################################################################################

.PHONY: all info build rebuild deploy run up destroy down rm create start stop
.PHONY: restart status logs logs-tail shell test clean

define BASEIMAGE_INFO
DOCKER_SIMPLE_CA_NAME:	$(DOCKER_SIMPLE_CA_NAME)

endef
export BASEIMAGE_INFO

all: destroy build start logs test

info: github-info docker-info
	@$(ECHO) "$${BASEIMAGE_INFO}"

build: docker-build

rebuild: docker-rebuild

deploy run up: destroy start

destroy down rm: docker-destroy

create: deploy-simple-ca docker-create
	@if [ -z "$$(docker container ps --quiet --filter name=^/$(DOCKER_CONTAINER_NAME)$$)" ]; then \
		DOCKER_SECRETS="$(addprefix $(DOCKER_HOME_DIR)/secrets/,ca_crt.pem)"; \
		$(ECHO) "Copying secrets $${DOCKER_SECRETS} to $(DOCKER_CONTAINER_NAME):/etc/ssl/certs"; \
		for DOCKER_SECRET in $${DOCKER_SECRETS}; do \
			docker cp $${DOCKER_SECRET} $(DOCKER_CONTAINER_NAME):/etc/ssl/certs/; \
		done; \
		DOCKER_SECRETS="$(addprefix $(DOCKER_HOME_DIR)/secrets/,ca_user.name ca_user.pwd server_key.pwd)"; \
		$(ECHO) "Copying secrets $${DOCKER_SECRETS} to $(DOCKER_CONTAINER_NAME):/etc/ssl/private"; \
		docker cp /var/empty $(DOCKER_CONTAINER_NAME):/etc/ssl/private; \
		for DOCKER_SECRET in $${DOCKER_SECRETS}; do \
			docker cp $${DOCKER_SECRET} $(DOCKER_CONTAINER_NAME):/etc/ssl/private/; \
		done; \
		$(MAKE) docker-start; \
	fi

start: create docker-start

stop: docker-stop

restart: stop start

status: docker-status

logs: start docker-logs

logs-tail: start docker-logs-tail

shell: start docker-shell

test: start docker-test

clean: destroy docker-clean
	@if [ "$(realpath $(CURDIR))" = "$(realpath $(DOCKER_HOME_DIR))" ]; then \
		DOCKER_SECRETS="$$(find secrets -type f | tr '\n' ' ')"; \
		if [ -n "$${DOCKER_SECRETS}" ]; then \
			$(ECHO) "Removing secrets: $${DOCKER_SECRETS}"; \
			chmod u+w $${DOCKER_SECRETS}; \
			rm -f $${DOCKER_SECRETS}; \
		fi; \
	fi

################################################################################

DOCKER_HOME_DIR		?= .
DOCKER_MK_DIR		?= $(DOCKER_HOME_DIR)/../Mk
include $(DOCKER_MK_DIR)/docker.container.mk

################################################################################

# Start Simple CA container to support tests
DOCKER_SIMPLE_CA_ID	= $(DOCKER_HOME_DIR)/.container_simple_ca_id
DOCKER_SIMPLE_CA_SECRETS= $(DOCKER_HOME_DIR)/.container_simple_ca_secrets
DOCKER_SIMPLE_CA_NAME	:= $(shell cat $(DOCKER_SIMPLE_CA_ID) 2> /dev/null || echo "$(DOCKER_CONTAINER_NAME)_simple_ca" )

.PHONY: deploy-simple-ca

deploy-simple-ca: $(DOCKER_HOME_DIR)/secrets/ca_user.pwd $(DOCKER_HOME_DIR)/secrets/server_key.pwd
	@set -e; \
	if [ -z "$$(docker container ps --all --quiet --filter name=^/$(DOCKER_SIMPLE_CA_NAME)$$)" ]; then \
		$(MAKE) docker-create \
			DOCKER_CONTAINER_ID=$(DOCKER_SIMPLE_CA_ID) \
			DOCKER_CONTAINER_NAME=$(DOCKER_SIMPLE_CA_NAME) \
			DOCKER_RUN_OPTS=" \
				-it \
				-e DOCKER_ENTRYPOINT_INFO=yes \
				-e SERVER_CRT_NAMES=simple-ca.local \
				-v /var/run/docker.sock:/var/run/docker.sock \
				--rm \
			"\
			DOCKER_IMAGE=$(DOCKER_PROJECT)/simple-ca \
			; \
		DOCKER_SECRETS="$$(find $(DOCKER_HOME_DIR)/secrets -type f | tr '\n' ' ')"; \
		$(ECHO) "Copying secrets $${DOCKER_SECRETS} to $(DOCKER_SIMPLE_CA_NAME):/var/lib/secrets"; \
		docker cp $(DOCKER_HOME_DIR)/secrets $(DOCKER_SIMPLE_CA_NAME):/var/lib/simple-ca; \
		$(MAKE) docker-start \
			DOCKER_CONTAINER_ID=$(DOCKER_SIMPLE_CA_ID) \
		; \
	fi

$(DOCKER_HOME_DIR)/secrets:
	@mkdir -p $(DOCKER_HOME_DIR)/secrets

$(DOCKER_HOME_DIR)/secrets/ca_user.pwd: | $(DOCKER_HOME_DIR)/secrets
	@$(MAKE) docker-rm \
		DOCKER_CONTAINER_ID=$(DOCKER_SIMPLE_CA_SECRETS) \
		; \
	DOCKER_CONTAINER_ID="$(DOCKER_SIMPLE_CA_NAME)_secrets"; \
	$(ECHO) "Deploying container: $${DOCKER_CONTAINER_ID}"; \
	$(ECHO) "$${DOCKER_CONTAINER_ID}" > $(DOCKER_SIMPLE_CA_SECRETS); \
	docker run \
		-it \
		-e DOCKER_ENTRYPOINT_INFO=yes \
		-v /var/run/docker.sock:/var/run/docker.sock \
		--name $${DOCKER_CONTAINER_ID} \
		$(DOCKER_PROJECT)/simple-ca secrets; \
	$(ECHO) -n "Copying secrets from $${DOCKER_CONTAINER_ID}:/var/lib/secrets to "; \
	docker cp $${DOCKER_CONTAINER_ID}:/var/lib/simple-ca/secrets $(DOCKER_HOME_DIR); \
	$(ECHO) "$$(find $(DOCKER_HOME_DIR)/secrets -type f | tr '\n' ' ')"; \
	$(MAKE) docker-rm DOCKER_CONTAINER_ID=$(DOCKER_SIMPLE_CA_SECRETS); \
	$(MAKE) docker-rm DOCKER_CONTAINER_ID=$(DOCKER_SIMPLE_CA_ID)

$(DOCKER_HOME_DIR)/secrets/server_key.pwd: | $(DOCKER_HOME_DIR)/secrets
	@openssl rand -hex 32 > $(DOCKER_HOME_DIR)/secrets/server_key.pwd

################################################################################

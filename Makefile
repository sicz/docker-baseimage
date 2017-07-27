################################################################################

BASEIMAGE_OS_NAME	?= Alpine Linux
BASEIMAGE_OS_URL	?= https://alpinelinux.org

BASEIMAGE_NAME		?= alpine
BASEIMAGE_TAG		?= 3.6

################################################################################

DOCKER_PROJECT		?= sicz
DOCKER_NAME		= baseimage-$(BASEIMAGE_NAME)
DOCKER_TAG		?= $(BASEIMAGE_TAG)
DOCKER_TAGS		?= latest
DOCKER_DESCRIPTION	= $(BASEIMAGE_OS_NAME) based image modified for Docker-friendliness
DOCKER_PROJECT_URL	= $(BASEIMAGE_OS_URL)

DOCKER_RUN_OPTS		+= -v /var/run/docker.sock:/var/run/docker.sock \
			   $(DOCKER_SHELL_OPTS)
#		   	   -v $(abspath $(DOCKER_HOME_DIR))/secrets/ca_crt.pem:/run/secrets/ca_crt.pem
#			   -v $(abspath $(DOCKER_HOME_DIR))/secrets/ca_user.pwd:/run/secrets/ca_user.pwd

DOCKER_FILE		= Dockerfile.$(BASEIMAGE_NAME)

DOCKER_SUBDIRS		= devel centos centos/devel

################################################################################

.PHONY: all info clean clean-all
.PHONY: build rebuild deploy run up destroy down rm start stop restart
.PHONY: status logs shell test

all: destroy build test
info: docker-info github-info
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
test: destroy deploy-simple-ca
	@DOCKER_RUN_OPTS="$(DOCKER_RUN_OPTS)"; \
	DOCKER_RUN_OPTS="$${DOCKER_RUN_OPTS} -v $(abspath $(DOCKER_HOME_DIR))/secrets/ca_crt.pem:/run/secrets/ca_crt.pem"; \
	DOCKER_RUN_OPTS="$${DOCKER_RUN_OPTS} -v $(abspath $(DOCKER_HOME_DIR))/secrets/ca_user.pwd:/run/secrets/ca_user.pwd"; \
	$(MAKE) start DOCKER_RUN_OPTS="$${DOCKER_RUN_OPTS}"; \
	$(MAKE) logs docker-test destroy-simple-ca
clean: destroy docker-clean clean-secrets
clean-all: ; @$(MAKE) docker-all TARGET=clean

################################################################################

# Start and destroy Simple CA container to support tests
DOCKER_SIMPLE_CA_ID	= .container_simple_ca_id

.PHONY: clean-secrets deploy-simple-ca destroy-simple-ca

clean-secrets:
	@if [ "$(realpath $(CURDIR))" = "$(realpath $(DOCKER_HOME_DIR))" ]; then \
		DOCKER_SECRETS="$$(ls secrets/* 2>/dev/null | tr '\n' ' ')"; \
		if [ -n "$${DOCKER_SECRETS}" ]; then \
			$(ECHO) "Removing secrets: $${DOCKER_SECRETS}"; \
			chmod u+w secrets/*; \
			rm -f $${DOCKER_SECRETS}; \
		fi; \
	fi

deploy-simple-ca: destroy-simple-ca
	@$(ECHO) -n "Deploying container: "; \
	DOCKER_SIMPLE_CA_ID="$(DOCKER_CONTAINER_NAME)_simple_ca"; \
	$(ECHO) $${DOCKER_SIMPLE_CA_ID} > $(DOCKER_SIMPLE_CA_ID); \
	docker run \
		-d \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $(abspath $(DOCKER_HOME_DIR))/secrets:/var/lib/simple-ca/secrets \
		--name $${DOCKER_SIMPLE_CA_ID} \
		--rm \
		$(DOCKER_PROJECT)/simple-ca > /dev/null; \
	i=0; \
	while [ ! -e $(DOCKER_HOME_DIR)/secrets/ca_crt.pem ]; do \
		if [ $$i -ge 30 ]; then \
			$(ECHO) "ERROR: timeout has been reached"; \
			docker logs $${DOCKER_SIMPLE_CA_ID}; \
			ls -al $(DOCKER_HOME_DIR)/secrets; \
			exit 1; \
		fi; \
		i=$$((i+1)); \
		sleep 1; \
	done; \
	$(ECHO) "$${DOCKER_SIMPLE_CA_ID}"; \
	docker logs $${DOCKER_SIMPLE_CA_ID}

destroy-simple-ca:
	@touch $(DOCKER_SIMPLE_CA_ID); \
	DOCKER_SIMPLE_CA_ID="$$(cat $(DOCKER_SIMPLE_CA_ID))"; \
	if [ -n "$${DOCKER_SIMPLE_CA_ID}" ]; then \
		if [ -n "$$(docker container ps --all --quiet --filter name=^/$${DOCKER_SIMPLE_CA_ID}$$)" ]; then \
			$(ECHO) -n "Destroying container: "; \
			docker container rm $(DOCKER_REMOVE_OPTS) -f $${DOCKER_SIMPLE_CA_ID} > /dev/null; \
			$(ECHO) "$${DOCKER_SIMPLE_CA_ID}"; \
		fi; \
	fi; \
	rm -f $(DOCKER_SIMPLE_CA_ID)

################################################################################

DOCKER_HOME_DIR		?= .
DOCKER_MK_DIR		?= $(DOCKER_HOME_DIR)/../Mk
include $(DOCKER_MK_DIR)/docker.container.mk

################################################################################

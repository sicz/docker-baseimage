### SHELL ######################################################################

# Replace Debian Almquist Shell with Bash
ifeq ($(realpath $(SHELL)),/bin/dash)
SHELL   		:= /bin/bash
endif

# Exit immediately if a command exits with a non-zero exit status
# TODO: .SHELLFLAGS does not exists on obsoleted macOS X-Code make
# .SHELLFLAGS		= -ec
SHELL			+= -e

### DOCKER_VARIANTS ############################################################

# Docker image variants
DOCKER_VARIANTS		+= alpine \
			   centos \
			   debian

# Make targets propagated to all Docker image variants
DOCKER_VARIANT_TARGETS	+= build \
			   rebuild \
			   ci \
			   clean \
			   docker-pull \
			   docker-pull-baseimage \
			   docker-pull-dependencies \
			   docker-pull-image \
			   docker-pull-testimage \
			   docker-push \
			   docker-load-image \
			   docker-save-image

### MAKE_TARGETS ###############################################################

# Build all images and run all tests
.PHONY: all
all: ci

# Subdir targets
.PHONY: $(DOCKER_VARIANT_TARGETS)
$(DOCKER_VARIANT_TARGETS):
	@for DOCKER_VARIANT in $(DOCKER_VARIANTS); do \
		cd $(CURDIR)/$${DOCKER_VARIANT}; \
		$(MAKE) $@; \
	done

################################################################################

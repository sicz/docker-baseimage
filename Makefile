### SHELL ######################################################################

# Replace Debian Almquist Shell with Bash
ifeq ($(realpath $(SHELL)),/bin/dash)
SHELL   		:= /bin/bash
endif

# Exit immediately if a command exits with a non-zero status
# TODO: .SHELLFLAGS does not exists on obsoleted macOS X-Code make
# .SHELLFLAGS		= -ec
SHELL			+= -e

### MAKE_TARGETS ###############################################################

# Docker image variants
DOCKER_VARIANTS		= dockerspec \
			  alpine \
			  centos \

# Make targets propagated to Docker image variants
DOCKER_VARIANT_TARGETS	= build-all \
			  rebuild-all \
			  ci-all \
			  clean-all \
			  docker-pull-all \
			  docker-pull-dependencies-all \
			  docker-pull-image-all \
			  docker-pull-testimage-all \
			  docker-push-all

# Project home directory
export PROJECT_DIR	= $(CURDIR)

################################################################################

# Make ci-all in all subdirs
.PHONY: all
all: ci-all

# Clean project
.PHONY: clean
clean: clean-all

# Subdir targets
.PHONY: $(DOCKER_VARIANT_TARGETS)
$(DOCKER_VARIANT_TARGETS):
	@for SUBDIR in $(DOCKER_VARIANTS); do \
		cd $(PROJECT_DIR)/$${SUBDIR}; \
		$(MAKE) $@; \
	done

### CIRCLE_CI ##################################################################

# Update Dockerspec tag in CircleCI configuration
.PHONY: ci-update-config
ci-update-config:
	@cd dockerspec; \
	$(MAKE) $@

################################################################################

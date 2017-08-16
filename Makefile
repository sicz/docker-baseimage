### MAKE_TARGETS ###############################################################

# Docker image variants
DOCKER_VARIANTS		= alpine \
			  dockerspec \
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

# Subdir targets
.PHONY: $(DOCKER_VARIANT_TARGETS)
$(DOCKER_VARIANT_TARGETS):
	@set -eo pipefail; \
	for SUBDIR in $(DOCKER_VARIANTS); do \
		cd $(PROJECT_DIR)/$${SUBDIR}; \
		$(MAKE) $@; \
	done

################################################################################

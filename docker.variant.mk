################################################################################

include ../docker.goals.mk
include ../docker.config.mk
include docker.config.mk

################################################################################

# GOAL-TAG:
# $1 - MAKE_GOAL
# $2 - DOCKER_TAG
define DOCKER_TAG_TARGETS
.PHONY: $(1)-$(2)
$(1)-$(2):
	@echo; echo; echo "===> $(DOCKER_PROJECT)/$(DOCKER_NAME):$(2)"
	@cd $(2); \
	$(MAKE) $(1)
endef

################################################################################

# GOAL: GOAL-TAG
# $1 - MAKE_GOAL
define MAKE_GOAL_TARGETS
.PHONY: $(1)
$(1): $(foreach DOCKER_TAG,$(DOCKER_TAGS),$(1)-$(DOCKER_TAG))
$(foreach DOCKER_TAG,$(DOCKER_TAGS),$(eval $(call DOCKER_TAG_TARGETS,$(1),$(DOCKER_TAG))))
endef
$(foreach MAKE_GOAL,$(MAKE_GOALS),$(eval $(call MAKE_GOAL_TARGETS,$(MAKE_GOAL))))

################################################################################

# TAG: all-TAG
# $1 - DOCKER_TAG
define DOCKER_GOAL_TARGET
.PHONY: $(1)
$(1):	all-$(1)
endef
$(foreach DOCKER_TAG,$(DOCKER_TAGS),$(eval $(call DOCKER_GOAL_TARGET,$(DOCKER_TAG))))

################################################################################

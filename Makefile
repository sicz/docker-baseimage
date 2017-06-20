################################################################################

# sicz/baseimage-VARIANT
DOCKER_VARIANTS		= alpine \
		   	  centos

################################################################################

include docker.goals.mk

################################################################################

# GOAL-VARIANT:
# $1 - MAKE_GOAL
# $2 - DOCKER_VARIANT
define DOCKER_VARIANT_TARGETS
.PHONY: $(2) $(1)-$(2)
$(1)-$(2):
	@cd $(2); \
	$(MAKE) $(1)
endef

################################################################################

# GOAL: GOAL-VARIANT
# $1 - MAKE_GOAL
define MAKE_GOAL_TARGETS
.PHONY: $(1)
$(1): $(foreach DOCKER_VARIANT,$(DOCKER_VARIANTS),$(1)-$(DOCKER_VARIANT))
$(foreach DOCKER_VARIANT,$(DOCKER_VARIANTS),$(eval $(call DOCKER_VARIANT_TARGETS,$(1),$(DOCKER_VARIANT))))
endef
$(foreach MAKE_GOAL,$(MAKE_GOALS),$(eval $(call MAKE_GOAL_TARGETS,$(MAKE_GOAL))))

################################################################################

# VARIANT: all-VARIANT
# $1 - DOCKER_VARIANT
define DOCKER_GOAL_TARGET
.PHONY: $(1)
$(1):	all-$(1)
endef
$(foreach DOCKER_VARIANT,$(DOCKER_VARIANTS),$(eval $(call DOCKER_GOAL_TARGET,$(DOCKER_VARIANT))))

################################################################################

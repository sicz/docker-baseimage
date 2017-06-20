################################################################################

# Default goal
.DEFAULT_GOAL		:= all

################################################################################

# Common goals
MAKE_GOALS		+= all \
			   build \
			   rebuild \
			   deploy \
			   run \
			   up \
			   destroy \
			   down \
			   clean \
			   rm \
			   start \
			   stop \
			   restart \
			   status \
			   logs \
			   test \
			   docker-pull-baseimage

################################################################################

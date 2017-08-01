################################################################################

DOCKER_NAME		= dockerspec
DOCKER_DESCRIPTION	= An image intended to run Docker image tests using RSpec and ServerSpec
DOCKER_PROJECT_URL	= http://serverspec.org

DOCKER_BUILD_VARS	+= DOCKER_VERSION

DOCKER_RUN_OPTS		+= -v $(abspath $(DOCKER_HOME_DIR))/.rspec:/.rspec \
			   -v $(abspath $(DOCKER_HOME_DIR))/spec:/spec

################################################################################

# Docker Compose file version:
# - docker: 3.3
# - docker-compose: 3.3
DOCKER_VERSION		?= 17.06.0-ce
DOCKER_COMPOSE_VERSION	?= 1.15.0

################################################################################

DOCKER_HOME_DIR		?= ..
include $(DOCKER_HOME_DIR)/Makefile

################################################################################

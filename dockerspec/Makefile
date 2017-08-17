### BASE_IMAGE #################################################################

BASE_IMAGE_NAME		?= alpine
BASE_IMAGE_TAG		?= $(BASE_IMAGE_OS_VERSION)

BASE_IMAGE_OS_FAMILY	?= $(BASE_IMAGE_NAME)
BASE_IMAGE_OS_NAME	?= Alpine Linux
BASE_IMAGE_OS_VERSION	?= 3.6
BASE_IMAGE_OS_URL	?= https://alpinelinux.org

### DOCKER_IMAGE ###############################################################

DOCKER_NAME		?= dockerspec
DOCKER_PROJECT_DESC	?= An image intended to run Docker image tests using RSpec and ServerSpec
DOCKER_PROJECT_URL	?= http://serverspec.org

DOCKER_IMAGE_TAGS	?= latest

DOCKER_VARIANT_DIR	?= $(PROJECT_DIR)/$(DOCKER_NAME)

### DOCKER_VERSIONS ############################################################

DOCKER_VERSIONS		?= latest devel

### BUILD ######################################################################

# Dockerfile lopcation
BUILD_DOCKER_FILE	?= $(abspath $(PROJECT_DIR)/$(BASE_IMAGE_NAME)/$(DOCKER_FILE))

# Docker image build variables
BUILD_VARS		+= DOCKER_VERSION \
			   DOCKER_COMPOSE_VERSION \
			   GEM_DOCKER_API_VERSION \
			   GEM_RSPEC_VERSION \
			   GEM_SERVERSPEC_VERSION \
			   RUBY_VERSION

# Docker Compose file version:
# - docker: 3.3
# - docker-compose: 3.3
DOCKER_VERSION		?= 17.06.0-ce
DOCKER_COMPOSE_VERSION	?= 1.15.0

RUBY_VERSION		?= 2.4.1-r3

GEM_DOCKER_API_VERSION	?= 1.33.6
GEM_RSPEC_VERSION	?= 3.6.0
GEM_SERVERSPEC_VERSION	?= 2.40.0

### MK_DOCKER_IMAGE ############################################################

PROJECT_DIR		?= $(abspath ..)
include $(PROJECT_DIR)/docker.version.mk

################################################################################


DOCKERFILES_DIR = dockerfiles
DOCKER_REPOSITORY ?=

VERSION ?=

ifeq ($(VERSION),)
  GIT_VERSION := $(shell git describe)
  VERSION := $(or $(GIT_VERSION),latest)
endif

DOCKERFILES = $(wildcard $(DOCKERFILES_DIR)/*)
DOCKER_IMAGES = $(foreach docker,$(DOCKERFILES),$(notdir $(docker)))

DOCKER_BUILD_TARGETS := $(foreach image,${DOCKER_IMAGES},docker-build/$(image))
DOCKER_PUSH_TARGETS := $(foreach image,${DOCKER_IMAGES},docker-push/$(image))

define target_to_image
  IMAGE := $$(lastword $$(subst /, ,$(1)))
  DOCKER_DIR := $(DOCKERFILES_DIR)/$$(IMAGE)
endef

define image_to_tag
  IMAGE_TAG := $(1):$(VERSION)
  ifneq ($(DOCKER_REPOSITORY),)
    IMAGE_TAG := $(DOCKER_REPOSITORY)/$$(IMAGE_TAG)
  endif
endef

${DOCKER_BUILD_TARGETS}:
	$(eval $(call target_to_image,$@))
	$(eval $(call image_to_tag,$(IMAGE)))
	@echo "=================================================="
	@echo "Building ${IMAGE} (Tagged: ${IMAGE_TAG})"
	@echo "=================================================="
	@docker build ${DOCKER_DIR} -t ${IMAGE_TAG}

docker-build: ${DOCKER_BUILD_TARGETS}

${DOCKER_PUSH_TARGETS}:
	$(eval $(call target_to_image,$@))
	$(eval $(call image_to_tag,$(IMAGE)))
	docker push ${IMAGE_TAG}

docker-push: ${DOCKER_PUSH_TARGETS}

# :vim set noexpandtab shiftwidth=8 softtabstop=0

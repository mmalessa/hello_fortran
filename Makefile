APP_NAME = hello_fortran
BASE_IMAGE = alpine:3.16

IMAGE_DEV = $(APP_NAME)-dev

DOCKERFILE_DEV = .docker/app/Dockerfile

.DEFAULT_GOAL = help
PID = /tmp/serving.pid
DEVELOPER_UID     ?= $(shell id -u)

MAKEFLAGS += --no-builtin-rules --no-builtin-variables
FC := gfortran
LD := $(FC)
RM := rm -f

SRCS:= hello.f90

OBJS := $(addsuffix .o, $(SRCS))
.PHONY: all clean

#-----------------------------------------------------------------------------------------------------------------------
ARG := $(word 2, $(MAKECMDGOALS))
%:
	@:
#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------

help: ## Outputs this help screen
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

init: init-image ## Alias for 'init-image'

init-image: ## Build dev image
	@docker build 											\
	    -t $(IMAGE_DEV)										\
		--build-arg BASE_IMAGE=$(BASE_IMAGE)			\
		--build-arg DEVELOPER_UID=$(DEVELOPER_UID)			\
		--build-arg APP_NAME=$(APP_NAME)					\
		-f $(DOCKERFILE_DEV)								\
		.
up: ## Start application dev container
	@cd .docker && \
	COMPOSE_PROJECT_NAME=$(APP_NAME) \
	IMAGE_DEV=$(IMAGE_DEV) \
	APP_NAME=$(APP_NAME) \
	docker-compose up -d

down: ## Remove application dev container
	@cd .docker && \
	COMPOSE_PROJECT_NAME=$(APP_NAME) \
	IMAGE_DEV=$(IMAGE_DEV) \
	APP_NAME=$(APP_NAME) \
	docker-compose down

console: ## Enter application dev container
	@docker exec -it -u developer $(APP_NAME)-dev bash
	
build: all ## Alias for all
all: $(APP_NAME) ## Build an application

$(APP_NAME): $(OBJS)
	$(LD) -o $@ $^

# dependencies between object files
# hello.f90.o: someother.f90.o other.mod

$(OBJS): %.o: %
	$(FC) -c -o $@ $<

$(OBJS): $(MAKEFILE_LIST)

clean: ## Clean 
	$(RM) $(filter %.o, $(OBJS)) $(wildcard *.mod) $(PROG)


include env_make

NS       = bodsch
VERSION ?= latest

REPO     = docker-dashing
NAME     = dashing
INSTANCE = default

BUILD_DATE := $(shell date +%Y-%m-%d)
BUILD_VERSION := $(shell date +%y%m)

D3_VERSION ?= 4.13.0
JQ_VERSION ?= 2.2.4
JQUI_VERSION ?= 1.12.1
FONT_AWESOME ?= 4.7.0


.PHONY: build push shell run start stop rm release

build:
	docker build \
		--force-rm \
		--compress \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg BUILD_VERSION=$(BUILD_VERSION) \
		--build-arg D3_VERSION=$(D3_VERSION) \
		--build-arg JQ_VERSION=$(JQ_VERSION) \
		--build-arg JQUI_VERSION=$(JQUI_VERSION) \
		--build-arg FONT_AWESOME=$(FONT_AWESOME) \
		--tag $(NS)/$(REPO):$(BUILD_VERSION) .

clean:
	docker rmi \
		--force \
		$(NS)/$(REPO):$(BUILD_VERSION)

history:
	docker history \
		$(NS)/$(REPO):$(BUILD_VERSION)

push:
	docker push \
		$(NS)/$(REPO):$(BUILD_VERSION)

shell:
	docker run \
		--rm \
		--name $(NAME)-$(INSTANCE) \
		--interactive \
		--tty \
		$(PORTS) \
		$(VOLUMES) \
		$(ENV) \
		$(NS)/$(REPO):$(BUILD_VERSION) \
		/bin/sh

run:
	docker run \
		--rm \
		--name $(NAME)-$(INSTANCE) \
		$(PORTS) \
		$(VOLUMES) \
		$(ENV) \
		$(NS)/$(REPO):$(BUILD_VERSION)

exec:
	docker exec \
		--interactive \
		--tty \
		$(NAME)-$(INSTANCE) \
		/bin/sh

start:
	docker run \
		--detach \
		--name $(NAME)-$(INSTANCE) \
		$(PORTS) \
		$(VOLUMES) \
		$(ENV) \
		$(NS)/$(REPO):$(BUILD_VERSION)

stop:
	docker stop \
		$(NAME)-$(INSTANCE)

rm:
	docker rm \
		$(NAME)-$(INSTANCE)

release: build
	make push -e VERSION=$(BUILD_VERSION)

default: build

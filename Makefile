
CONTAINER  := dashing
IMAGE_NAME := docker-dashing

.PHONY: build push shell run start stop rm release

build:
	docker build \
		--tag=$(IMAGE_NAME) .
	@echo Image tag: ${IMAGE_NAME}

clean:
	docker rm \
		--force \
		${CONTAINER}

run:
	docker run \
		--rm \
		--detach \
		--interactive \
		--tty \
		--publish=3030:3030 \
		--env ICINGA_HOST="192.168.33.5" \
		--env ICINGA_API_USER="root" \
		--env ICINGA_API_PASSWORD="icinga" \
		--env ICINGAWEB_URL="http://192.168.33.5/icingaweb2" \
		--hostname=${CONTAINER} \
		--name=${CONTAINER} \
		$(IMAGE_NAME)

shell:
	docker run \
		--rm \
		--interactive \
		--publish=3030:3030 \
		--env ICINGA_HOST="192.168.33.5" \
		--env ICINGA_API_USER="root" \
		--env ICINGA_API_PASSWORD="icinga" \
		--env ICINGAWEB_URL="http://192.168.33.5/icingaweb2" \
		--tty \
		--hostname=${CONTAINER} \
		--name=${CONTAINER} \
		--entrypoint '' \
		$(IMAGE_NAME) \
		/bin/sh

exec:
	docker exec \
		--interactive \
		--tty \
		${CONTAINER} \
		/bin/sh

stop:
	docker kill ${CONTAINER}

history:
	docker history ${IMAGE_NAME}

default: build

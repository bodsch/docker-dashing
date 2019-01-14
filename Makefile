export GIT_SHA1          := $(shell git rev-parse --short HEAD)
export DOCKER_IMAGE_NAME := dashing
export DOCKER_NAME_SPACE := ${USER}
export DOCKER_VERSION    ?= latest
export BUILD_DATE        := $(shell date +%Y-%m-%d)
export BUILD_VERSION     := $(shell date +%y%m)
export BUILD_TYPE        ?= stable
export SMASHING_VERSION  ?= 1.1.0
export D3_VERSION        ?= 4.13.0
export JQ_VERSION        ?= 2.2.4
export JQUI_VERSION      ?= 1.12.1
export FONT_AWESOME      ?= 4.7.0


.PHONY: build shell run exec start stop clean

default: build

build:
	@hooks/build

shell:
	@hooks/shell

run:
	@hooks/run

exec:
	@hooks/exec

start:
	@hooks/start

stop:
	@hooks/stop

clean:
	@hooks/clean

linter:
	@tests/linter.sh

test: linter

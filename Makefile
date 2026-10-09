SHELL := /bin/bash

OLD_SOLANA_VERSION ?= v4.2.1
MANUAL_CARGO_BUILD_SBF_VERSION ?= 4.2.0
CANDIDATE_CARGO_BUILD_SBF_VERSION ?= 4.4.0
AGAVE_PR_COMMIT ?= a7c5efc84bdd645574185bc4b6efc3e0cd716851
DOCKER_PLATFORM ?= linux/amd64

DOCKER_ENV = \
	-e OLD_SOLANA_VERSION=$(OLD_SOLANA_VERSION) \
	-e MANUAL_CARGO_BUILD_SBF_VERSION=$(MANUAL_CARGO_BUILD_SBF_VERSION) \
	-e CANDIDATE_CARGO_BUILD_SBF_VERSION=$(CANDIDATE_CARGO_BUILD_SBF_VERSION) \
	-e AGAVE_PR_COMMIT=$(AGAVE_PR_COMMIT)

.PHONY: all scenario-1 scenario-2 scenario-3 build-1 build-2 build-3 clean

all: scenario-1 scenario-2 scenario-3

build-1:
	docker build --platform $(DOCKER_PLATFORM) --file scenario-1/Dockerfile --tag cargo-build-sbf-scenario-1 .

build-2:
	docker build --platform $(DOCKER_PLATFORM) --file scenario-2/Dockerfile --tag cargo-build-sbf-scenario-2 .

build-3:
	docker build --platform $(DOCKER_PLATFORM) --file scenario-3/Dockerfile --tag cargo-build-sbf-scenario-3 .

scenario-1: build-1
	docker run --rm --platform $(DOCKER_PLATFORM) $(DOCKER_ENV) cargo-build-sbf-scenario-1

scenario-2: build-2
	docker run --rm --platform $(DOCKER_PLATFORM) $(DOCKER_ENV) cargo-build-sbf-scenario-2

scenario-3: build-3
	docker run --rm --platform $(DOCKER_PLATFORM) $(DOCKER_ENV) cargo-build-sbf-scenario-3

clean:
	docker image rm $$(docker image ls --quiet 'cargo-build-sbf-scenario-*') 2>/dev/null || true

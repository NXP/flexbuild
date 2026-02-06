
.PHONY: build
.ONESHELL:
SHELL := /bin/bash

http_proxy  ?=
https_proxy ?=
no_proxy    ?=

IMAGE := fbdebian:13

build:
	@set -e; \
	ARGS=""; \
	if [ -n "$(http_proxy)" ] || [ -n "$(https_proxy)" ]; then \
		if [ -z "$(http_proxy)" ] || [ -z "$(https_proxy)" ]; then \
			echo "Please set BOTH http_proxy and https_proxy!" >&2; exit 1; \
		fi; \
		ARGS+=" --build-arg http_proxy=$(http_proxy) --build-arg https_proxy=$(https_proxy)"; \
		ARGS+=" --build-arg HTTP_PROXY=$(http_proxy) --build-arg HTTPS_PROXY=$(https_proxy)"; \
	fi; \

	if [ -n "$(no_proxy)" ]; then \
		ARGS+=" --build-arg no_proxy=$(no_proxy) --build-arg NO_PROXY=$(no_proxy)"; \
	fi; \

	#echo "docker build -t $(IMAGE) --network host $$ARGS ."; \
	#docker build -t $(IMAGE) --network host .
	docker build -t $(IMAGE) --network host $$ARGS .

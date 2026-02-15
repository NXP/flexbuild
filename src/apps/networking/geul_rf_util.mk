# Copyright 2023-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
CONFIG_APP_GEUL_RF_UTIL ?= n

geul_rf_util:
	@set -e; \
	if [ "$(strip $(CONFIG_APP_GEUL_RF_UTIL))" != "y" ]; then \
		echo "Skipping geul_rf_util: CONFIG_APP_GEUL_RF_UTIL!='y' (current='$(strip $(CONFIG_APP_GEUL_RF_UTIL))')"; \
		exit 0; \
	fi && \
	$(call download_repo,geul_rf_util,apps/networking,git) &&\
	$(call fbprint_b,"geul_rf_util") &&\
	if [ ! -d $(NETDIR)/freertos_la931x ]; then $(call download_repo,freertos_la931x,apps/networking,git); fi && \
	cd $(NETDIR)/geul_rf_util && \
	export PYTHON_INCLUDE=$(RFSDIR)/usr/include/python3.13; \
	export KERNEL_DIR=$(KERNEL_OUTPUT_PATH)/$(KERNEL_BRANCH) && export COMMON_HEADERS_DIR=$(NETDIR)/geul_common_headers && \
	$(MAKE) clean && $(MAKE) ABERDEEN=0 MOTHERWELL=1 ICEWINGS=1 YUCCA=1 $(LOG_MUTE) && $(MAKE) MOTHERWELL=1 ICEWINGS=1 YUCCA=1 install && \
	mkdir -p $(DESTDIR)/root/rf-ctrl && \
	cp -rf python/rf-ctrl/* $(DESTDIR)/root/rf-ctrl/ && \
	$(call fbprint_d,"geul_rf_util")

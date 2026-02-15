# Copyright 2023-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
CONFIG_APP_SLAB_DRIVER ?= n

slab_driver:
	@set -e; \
	if [ "$(strip $(CONFIG_APP_SLAB_DRIVER))" != "y" ]; then \
		echo "Skipping slab_driver: CONFIG_APP_SLAB_DRIVER!='y' (current='$(strip $(CONFIG_APP_SLAB_DRIVER))')"; \
		exit 0; \
	fi && \
	$(call download_repo,slab_driver,apps/networking,git) && \
	$(call fbprint_b,"slab_driver") && \
	cd $(NETDIR)/slab_driver/scripts && \
	mkdir -p $(DESTDIR)/usr/local/timing && \
	cp -rf * $(DESTDIR)/usr/local/timing/
	$(call fbprint_d,"slab_driver")

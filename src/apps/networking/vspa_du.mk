# Copyright 2023-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
CONFIG_APP_VSPA_DU ?= n

vspa_du:
	@set -e; \
	if [ "$(strip $(CONFIG_APP_VSPA_DU))" != "y" ]; then \
		echo "Skipping vspa_du: CONFIG_APP_VSPA_DU!='y' (current='$(strip $(CONFIG_APP_VSPA_DU))')"; \
		exit 0; \
	fi && \
	$(call download_repo,vspa_du,apps/networking,git) && \
	$(call fbprint_b,"vspa_du") && \
	mkdir -p $(DESTDIR)/lib/firmware/ && \
	cd $(NETDIR)/vspa_du/la1224-vspa-app/bin/rdb/ && \
	cp -rf * $(DESTDIR)/lib/firmware/
	$(call fbprint_d,"vspa_du")

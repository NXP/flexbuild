# Copyright 2023-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
CONFIG_APP_VSPA_REF_APP ?= n

vspa_ref_app:
	@set -e; \
	if [ "$(strip $(CONFIG_APP_VSPA_REF_APP))" != "y" ]; then \
		echo "Skipping vspa_ref_app: CONFIG_APP_VSPA_REF_APP!='y' (current='$(strip $(CONFIG_APP_VSPA_REF_APP))')"; \
		exit 0; \
	fi && \
	$(call download_repo,vspa_ref_app,apps/networking,git) && \
	$(call fbprint_b,"vspa_ref_app") && \
	mkdir -p $(DESTDIR)/lib/firmware/ && \
	cd $(NETDIR)/vspa_ref_app/L1-RefApp/binaries/ && \
	sudo cp -rf * $(DESTDIR)/lib/firmware/
	$(call fbprint_d,"vspa_ref_app")

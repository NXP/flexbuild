# Copyright 2023-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
CONFIG_APP_VSPA_FECA ?= n

vspa_feca:
	@set -e; \
	if [ "$(strip $(CONFIG_APP_VSPA_FECA))" != "y" ]; then \
		echo "Skipping vspa_feca: CONFIG_APP_VSPA_FECA!='y' (current='$(strip $(CONFIG_APP_VSPA_FECA))')"; \
		exit 0; \
	fi && \
	$(call download_repo,vspa_feca,apps/networking,git) && \
	$(call fbprint_b,"vspa_feca") && \
	mkdir -p $(DESTDIR)/lib/firmware/ && \
	cd $(NETDIR)/vspa_feca/la1224-vspa-app/bin/rdb/ && \
	cp -rf * $(DESTDIR)/lib/firmware/
	$(call fbprint_d,"vspa_feca")

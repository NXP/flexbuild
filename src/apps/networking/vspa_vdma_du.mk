# Copyright 2023-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
CONFIG_APP_VSPA_VDMA_DU ?= n

vspa_vdma_du:
	@set -e; \
	if [ "$(strip $(CONFIG_APP_VSPA_VDMA_DU))" != "y" ]; then \
		echo "Skipping vspa_vdma_du: CONFIG_APP_VSPA_VDMA_DU!='y' (current='$(strip $(CONFIG_APP_VSPA_VDMA_DU))')"; \
		exit 0; \
	fi && \
	$(call download_repo,vspa_vdma_du,apps/networking,git) && \
	$(call fbprint_b,"vspa_vdma_du") && \
	mkdir -p $(DESTDIR)/lib/firmware/ && \
	cd $(NETDIR)/vspa_vdma_du/la1224-vspa-app/bin/rdb/ && \
	cp -rf * $(DESTDIR)/lib/firmware/
	$(call fbprint_d,"vspa_vdma_du")

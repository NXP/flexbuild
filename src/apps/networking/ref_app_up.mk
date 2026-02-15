# Copyright 2023-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
CONFIG_APP_REF_APP_UP ?= n

ref_app_up:
	@set -e; \
	if [ "$(strip $(CONFIG_APP_REF_APP_UP))" != "y" ]; then \
		echo "Skipping ref_app_up: CONFIG_APP_REF_APP_UP!='y' (current='$(strip $(CONFIG_APP_REF_APP_UP))')"; \
		exit 0; \
	fi && \
	$(call download_repo,ref_app_up,apps/networking,git) && \
	$(call fbprint_b,"ref_app_up") && \
	cd $(NETDIR)/ref_app_up/rup && \
	mkdir -p $(DESTDIR)/root/rup && \
	cp -rf * $(DESTDIR)/root/rup/ && \
	$(call fbprint_d,"ref_app_up")

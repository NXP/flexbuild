# Copyright 2023-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
CONFIG_APP_SW_UCI_POLOR_DEC ?= n

sw_uci_polar_dec:
	@set -e; \
	if [ "$(strip $(CONFIG_APP_SW_UCI_POLOR_DEC))" != "y" ]; then \
		echo "Skipping sw_uci_polar_dec: CONFIG_APP_SW_UCI_POLOR_DEC!='y' (current='$(strip $(CONFIG_APP_SW_UCI_POLOR_DEC))')"; \
		exit 0; \
	fi && \
	$(call download_repo,sw_uci_polar_dec,apps/networking,git) && \
	$(call fbprint_b,"sw_uci_polar_dec") && \
	cd $(NETDIR)/sw_uci_polar_dec && \
	mkdir -p $(DESTDIR)/root/sw_uci_polar_dec && \
	cp -rf * $(DESTDIR)/root/sw_uci_polar_dec/
	$(call fbprint_d,"sw_uci_polar_dec")

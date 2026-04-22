# Copyright 2025-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# neutron NPU firmware on imx95
neutron:
	@$(call download_repo,neutron,apps/ml)
	$(call patch_apply,neutron,apps/ml)
	$(call fbprint_b,"neutron")
	cd $(MLDIR)/neutron
	install -d $(DESTDIR)/lib/firmware
	install -m 0644 imx95/firmware/* $(DESTDIR)/lib/firmware
	install -d $(DESTDIR)/usr/include/neutron
	mkdir -p $(DESTDIR)/usr/lib
	cp -af imx95/include/* $(DESTDIR)/usr/include/neutron
	cp --no-preserve=ownership -af imx95/library/* $(DESTDIR)/usr/lib/
	$(call fbprint_d,"neutron")

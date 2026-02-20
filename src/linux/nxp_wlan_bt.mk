# Copyright 2021-2024,2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# NXP WiFi + Bluetooth SDK for IW612, W8997, W8987, W9098, etc

# https://www.nxp.com/products/wireless/wi-fi-plus-bluetooth


nxp_wlan_bt:
	@$(call download_repo,nxp_wlan_bt,linux)
	$(call patch_apply,nxp_wlan_bt,linux)
	$(call fbprint_b,"nxp_wlan_bt")
	export INSTALL_MOD_PATH=$(KOUTDIR)/tmp
	cd $(PKGDIR)/linux/nxp_wlan_bt
	$(MAKE) build KERNELDIR=$(KERNEL_PATH) O=$(KOUTDIR) -C $(PKGDIR)/linux/nxp_wlan_bt $(LOG_MUTE)
	install -d $(KOUTDIR)/tmp/lib/modules/*/kernel/drivers/net/wireless/nxp
	cp -f mlan.ko moal.ko $(KOUTDIR)/tmp/lib/modules/*/updates/
	$(call fbprint_d,"nxp_wlan_bt")

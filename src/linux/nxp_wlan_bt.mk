# Copyright 2021-2024,2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# NXP WiFi + Bluetooth SDK for IW612, W8997, W8987, W9098, etc

# https://www.nxp.com/products/wireless/wi-fi-plus-bluetooth


nxp_wlan_bt: $(KERNEL_IMAGE)
	@$(call download_repo,nxp_wlan_bt,linux)
	$(call patch_apply,nxp_wlan_bt,linux)
	$(call fbprint_b,"nxp_wlan_bt")
	export INSTALL_MOD_PATH=$(DESTDIR)
	cd $(PKGDIR)/linux/nxp_wlan_bt
	krelease=$$(cat "$(KOUTDIR)/include/config/kernel.release" 2>/dev/null)
	$(MAKE) build KERNELDIR=$(KERNEL_PATH) O=$(KOUTDIR) -C $(PKGDIR)/linux/nxp_wlan_bt \
		BINDIR=$(DESTDIR)/lib/modules/"$$krelease"/updates $(LOG_MUTE)
	rm -f $(DESTDIR)/lib/modules/"$$krelease"/updates/README
	$(call fbprint_d,"nxp_wlan_bt")

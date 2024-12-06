# Copyright 2021-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# NXP WiFi + Bluetooth SDK for IW612, W8997, W8987, W9098, etc

# https://www.nxp.com/products/wireless/wi-fi-plus-bluetooth


nxp_wlan_bt:
	@[ $(SOCFAMILY) != IMX -o $(DISTROVARIANT) = base -o $(DISTROVARIANT) = tiny ] && exit || \
	 $(call fbprint_b,"nxp_wlan_bt") && \
	 $(call repo-mngr,fetch,linux,linux) 1>/dev/null && \
	 $(call repo-mngr,fetch,nxp_wlan_bt,apps/connectivity) && \
	 curbrch=`cd $(KERNEL_PATH) && git branch | grep ^* | cut -d' ' -f2` && \
	 kerneloutdir=$(KERNEL_OUTPUT_PATH)/$$curbrch && \
	 if [ ! -f $$kerneloutdir/include/generated/autoconf.h ]; then \
	     bld linux -a $(DESTARCH) -p $(SOCFAMILY); \
	 fi && \
	 export INSTALL_MOD_PATH=$$kerneloutdir/tmp && \
	 cd $(PKGDIR)/apps/connectivity/nxp_wlan_bt && \
	 if [ -d $(FBDIR)/patch/nxp_wlan_bt ] && [ ! -f .patchdone ]; then \
	     git am $(FBDIR)/patch/nxp_wlan_bt/*.patch && touch .patchdone; \
	 fi && \
	 \
	 make build KERNELDIR=$(KERNEL_PATH) O=$$kerneloutdir && \
	 kernelrelease=`cat $(KERNEL_OUTPUT_PATH)/$$curbrch/include/config/kernel.release` && \
	 mkdir -p $(DESTDIR)/usr/share/nxp_wireless && \
	 install -d $$kerneloutdir/tmp/lib/modules/$$kernelrelease/kernel/drivers/net/wireless/nxp && \
	 cp -f mlan.ko moal.ko $$kerneloutdir/tmp/lib/modules/$$kernelrelease/kernel/drivers/net/wireless/nxp && \
	 cp -f bin_wlan/{load,unload,README} $(DESTDIR)/usr/share/nxp_wireless/ && \
	 $(call fbprint_d,"nxp_wlan_bt")

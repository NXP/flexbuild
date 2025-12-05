# Copyright 2021-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# NXP WiFi + Bluetooth SDK for IW612, W8997, W8987, W9098, etc

# https://www.nxp.com/products/wireless/wi-fi-plus-bluetooth


nxp_wlan_bt:
	@[ $(SOCFAMILY) != IMX  ] && exit || \
	 $(call download_repo,linux,linux) 1>/dev/null && \
	 $(call download_repo,nxp_wlan_bt,linux) && \
	 kerneloutdir=$(KERNEL_OUTPUT_PATH)/$(KERNEL_BRANCH) && \
	 export INSTALL_MOD_PATH=$$kerneloutdir/tmp && \
	 $(call fbprint_b,"nxp_wlan_bt") && \
	 cd $(PKGDIR)/linux/nxp_wlan_bt && \
	 $(call patch_apply,nxp_wlan_bt,linux) && \
	 \
	 $(MAKE) build KERNELDIR=$(KERNEL_PATH) O=$$kerneloutdir -j$(JOBS) $(LOG_MUTE) && \
	 kernelrelease=`cat $(KERNEL_OUTPUT_PATH)/$(KERNEL_BRANCH)/include/config/kernel.release` && \
	 mkdir -p $(DESTDIR)/usr/share/nxp_wireless && \
	 install -d $$kerneloutdir/tmp/lib/modules/$$kernelrelease/kernel/drivers/net/wireless/nxp && \
	 cp -f mlan.ko moal.ko $$kerneloutdir/tmp/lib/modules/$$kernelrelease/updates/ && \
	 cp -f README $(DESTDIR)/usr/share/nxp_wireless/ && \
	 $(call fbprint_d,"nxp_wlan_bt")

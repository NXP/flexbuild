# Copyright 2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# NXP WiFi + Bluetooth SDK for 88w8997, 88w8987, 88w9098, etc

# https://www.nxp.com/products/wireless/wi-fi-plus-bluetooth


nxp_wlan_bt:
ifeq ($(CONFIG_NXP_WIFI_BT), "y")
	@[ $(DISTROSCALE) = tiny ] && exit || \
	 $(call fbprint_b,"nxp_wlan_bt") && \
	 $(call repo-mngr,fetch,linux,linux) 1>/dev/null && \
	 $(call repo-mngr,fetch,nxp_wlan_bt,apps/connectivity) && \
	 curbrch=`cd $(KERNEL_PATH) && git branch | grep ^* | cut -d' ' -f2` && \
	 kerneloutdir=$(KERNEL_OUTPUT_PATH)/$$curbrch && \
	 if [ ! -f $$kerneloutdir/include/generated/autoconf.h ]; then \
             bld -c linux -a $(DESTARCH) -p $(SOCFAMILY) -f $(CFGLISTYML); \
         fi && \
	 export INSTALL_MOD_PATH=$$kerneloutdir/tmp && \
	 cd $(PKGDIR)/apps/connectivity/nxp_wlan_bt/mxm_wifiex/wlan_src && \
	 \
	 make build KERNELDIR=$(KERNEL_PATH) O=$$kerneloutdir && \
	 mkdir -p $$kerneloutdir/tmp/lib/modules/*/extra && \
	 install -d $(DESTDIR)/opt/nxp_wireless && \
	 cp -f mlan.ko moal.ko $$kerneloutdir/tmp/lib/modules/*/extra/ && \
	 cp -rf ../bin_wlan/* $(DESTDIR)/opt/nxp_wireless && \
	 ls -l $(DESTDIR)/opt/nxp_wireless && \
	 $(call fbprint_d,"nxp_wlan_bt")
endif

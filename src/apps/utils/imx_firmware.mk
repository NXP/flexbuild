# Copyright 2017-2025 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



imx_firmware:
	@[ $(SOCFAMILY) != IMX ] && exit || \
	 $(call download_repo,imx_firmware,apps/utils) && \
	 $(call patch_apply,imx_firmware,apps/utils) && \
	 cd $(UTILSDIR)/imx_firmware && \
	 mkdir -p $(DESTDIR)/lib/firmware/{nxp,imx,brcm} $(LOG_MUTE) && \
	 echo Installing NXP WIFI/BT firmware && \
	 cp -f $(UTILSDIR)/imx_firmware/nxp/FwImage_*/* $(DESTDIR)/lib/firmware/nxp 2>/dev/null || true && \
	 cp -f $(UTILSDIR)/imx_firmware/nxp/mfguart/*.bin $(DESTDIR)/lib/firmware/nxp && \
	 cp -f $(UTILSDIR)/imx_firmware/nxp/wifi_mod_para.conf $(DESTDIR)/lib/firmware/nxp && \
	 echo Installing Murata WIFI/BT firmware && \
	 cp -f $(UTILSDIR)/imx_firmware/cyw-wifi-bt/*/{*.bin,*.clm_blob,*.txt} $(DESTDIR)/lib/firmware/brcm/ && \
	 cp -f $(UTILSDIR)/imx_firmware/cyw-wifi-bt/*/*.hcd $(DESTDIR)/lib/firmware/ && \
	 $(call fbprint_d,"imx_firmware")

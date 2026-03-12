# Copyright 2017-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



imx_firmware:
	@$(call download_repo,imx_firmware,apps/utils)
	 $(call patch_apply,imx_firmware,apps/utils)
	 cd $(UTILSDIR)/imx_firmware
	 mkdir -p $(DESTDIR)/lib/firmware/{nxp,imx,brcm} $(LOG_MUTE)
	 echo Installing NXP WIFI/BT firmware
	 cp -f $(UTILSDIR)/imx_firmware/FwImage_*/* $(DESTDIR)/lib/firmware/nxp 2>/dev/null || true
	 cp -f $(UTILSDIR)/imx_firmware/mfguart/*.bin $(DESTDIR)/lib/firmware/nxp
	 cp -f $(UTILSDIR)/imx_firmware/wifi_mod_para.conf $(DESTDIR)/lib/firmware/nxp
	 $(call fbprint_d,"imx_firmware")

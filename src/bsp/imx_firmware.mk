# Copyright 2017-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



imx_firmware:
	@[ $(SOCFAMILY) != IMX ] && exit || \
	 $(call download_repo,imx_firmware,bsp) && \
	 cd $(BSPDIR)/imx_firmware && \
	 mkdir -p $(FBOUTDIR)/bsp/imx_firmware/lib/firmware/{nxp,imx,brcm} $(LOG_MUTE) && \
	 echo Installing NXP WIFI/BT firmware && \
	 cp -f $(BSPDIR)/imx_firmware/nxp/FwImage_*/* $(FBOUTDIR)/bsp/imx_firmware/lib/firmware/nxp 2>/dev/null || true && \
	 cp -f $(BSPDIR)/imx_firmware/nxp/mfguart/*.bin $(FBOUTDIR)/bsp/imx_firmware/lib/firmware/nxp && \
	 cp -f $(BSPDIR)/imx_firmware/nxp/wifi_mod_para.conf $(FBOUTDIR)/bsp/imx_firmware/lib/firmware/nxp && \
	 echo Installing Murata WIFI/BT firmware && \
	 cp -f $(BSPDIR)/imx_firmware/cyw-wifi-bt/*/{*.bin,*.clm_blob,*.txt} $(FBOUTDIR)/bsp/imx_firmware/lib/firmware/brcm/ && \
	 cp -f $(BSPDIR)/imx_firmware/cyw-wifi-bt/*/*.hcd $(FBOUTDIR)/bsp/imx_firmware/lib/firmware/ && \
	 \
	 echo Installing firmware-imx for ddr,hdmi,dp,vpu,easrc,epdc,xcvr,xuvi && \
	 if [ ! -d $(BSPDIR)/firmware-imx ]; then \
	     cd $(BSPDIR) && rm -f firmware_imx.bin; \
		 $(WGET) $(repo_firmware_imx_bin_url) -O firmware_imx.bin $(LOG_MUTE); \
		 [ $$? -ne 0 ] && { echo "Downloading $(repo_firmware_imx_bin_url) failed."; exit 1; } || \
	     chmod +x firmware_imx.bin; \
	     ./firmware_imx.bin --auto-accept --force $(LOG_MUTE); \
		 mv firmware-imx* firmware-imx && rm -f firmware_imx.bin; \
	 fi && \
	 cp -Prf $(BSPDIR)/firmware-imx/firmware/* $(FBOUTDIR)/bsp/imx_firmware/lib/firmware/imx/ && \
	 $(call fbprint_d,"imx_firmware")

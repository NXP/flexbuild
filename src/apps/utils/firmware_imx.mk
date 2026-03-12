# Copyright 2017-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



firmware_imx:
	@$(call dl_by_wget,firmware_imx_bin,firmware_imx.bin)
	echo Installing firmware-imx for ddr,hdmi,dp,vpu etc
	cd "$(UTILSDIR)"
	if [ ! -d "$(UTILSDIR)"/firmware_imx ]; then \
		chmod +x "$(FBDIR)"/dl/firmware_imx.bin; \
		"$(FBDIR)"/dl/firmware_imx.bin --auto-accept --force $(LOG_MUTE); \
		mv firmware-imx-* firmware_imx; \
	fi
	cd $(UTILSDIR)/firmware_imx
	mkdir -p $(DESTDIR)/lib/firmware/imx
	rsync -a ./firmware/ $(DESTDIR)/lib/firmware/imx/  --exclude=ddr
	if [ "$(CONFIG_SOC_IMX8)" = "y" ]; then \
		mkdir -p $(DESTDIR)/lib/firmware/amphion/vpu; \
		cp -f ./firmware/vpu/vpu_fw_imx8* $(DESTDIR)/lib/firmware/amphion/vpu; \
	elif [ "$(CONFIG_SOC_IMX95)" = "y" ]; then \
		cp -f ./firmware/vpu/wave633c_codec_fw.bin $(DESTDIR)/lib/firmware; \
	elif [ "$(CONFIG_SOC_LS1028ARDB)" = "y" ]; then \
		ln -sf "$(UTILSDIR)"/firmware_imx/firmware/hdmi/cadence "$(FBOUTDIR)"/bsp/dp_fw_cadence; \
	fi
	$(call fbprint_d,"firmware_imx")

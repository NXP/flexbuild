# Copyright 2017-2025 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



firmware_imx:
	@[ $(SOCFAMILY) != IMX -a $${MACHINE:0:7} != ls1028a ] && exit || \
	$(call dl_by_wget,firmware_imx_bin,firmware_imx.bin) && \
	echo Installing firmware-imx for ddr,hdmi,dp,vpu,easrc,epdc,xcvr,xuvi && \
	cd $(UTILSDIR) && \
	if [ ! -d "$(UTILSDIR)"/firmware_imx ]; then \
		chmod +x $(FBDIR)/dl/firmware_imx.bin; \
		$(FBDIR)/dl/firmware_imx.bin --auto-accept --force $(LOG_MUTE); \
		mv firmware-imx-* firmware_imx; \
	fi && \
	cd $(UTILSDIR)/firmware_imx && \
	mkdir -p $(DESTDIR)/lib/firmware/imx && \
	rsync -a ./firmware/ $(DESTDIR)/lib/firmware/imx/  --exclude=ddr && \
	echo $(FBOUTDIR)/bsp/dp_fw_cadence && \
	case $(MACHINE) in \
		imx95*) cp ./firmware/vpu/wave633c_codec_fw.bin $(DESTDIR)/lib/firmware ;; \
		ls1028a*) ln -sf ./firmware/hdmi/cadence $(FBOUTDIR)/bsp/dp_fw_cadence ;; \
	esac && \
	$(call fbprint_d,"Installing [Done]")

# Copyright 2021-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# i.MX M4/M7/M33 core Demo images

IMX_MCORE_VERSION ?= 2.16.000

MCORE_LIST ?= imx8mm-m4 imx8mq-m4 imx8mn-m7 imx8mp-m7 imx8ulp-m33 imx93-m33 imx95-m7

FW_DOWNLOAD_URL ?= https://www.nxp.com/lgfiles/NMG/MAD/YOCTO


mcore_demo:
	@[ $(SOCFAMILY) != IMX ] && exit || \
	 if [ ! -d $(BSPDIR)/imx_mcore_demos ]; then \
	     mkdir -p $(BSPDIR)/imx_mcore_demos && \
	     cd $(BSPDIR)/imx_mcore_demos && \
	     for soc in $(MCORE_LIST); do \
		wget -q $(FW_DOWNLOAD_URL)/$${soc}-demo-$(IMX_MCORE_VERSION).bin -O $${soc}.bin && \
		chmod +x $${soc}.bin && ./$${soc}.bin --auto-accept && \
		mv $${soc}-demo-$(IMX_MCORE_VERSION) $${soc}-demo && \
		rm -f $${soc}.bin; \
	     done; \
	 fi && \
	 [ ! -L $(FBOUTDIR)/bsp/imx_mcore_demos ] && ln -sf $(BSPDIR)/imx_mcore_demos $(FBOUTDIR)/bsp/imx_mcore_demos || true && \
	 $(call fbprint_d,"imx_mcore_demo")

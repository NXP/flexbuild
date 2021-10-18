# Copyright 2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# i.MX mcore demo firmware


MCORE_VERSION ?= 2.10.0

MCORE_LIST ?= imx8mm-m4 imx8mq-m4 imx8mn-m7 imx8mp-m7 imx8ulp-m33

FW_DOWNLOAD_URL ?= http://yb2.am.freescale.net


mcore_demo:
	@[ $(SOCFAMILY) != IMX ] && exit || \
	 if [ ! -d $(BSPDIR)/imx_mcore_demos ]; then \
	     mkdir -p $(BSPDIR)/imx_mcore_demos && \
	     cd $(BSPDIR)/imx_mcore_demos && \
	     for soc in $(MCORE_LIST); do \
		wget -q $(FW_DOWNLOAD_URL)/$${soc}-demo-$(MCORE_VERSION).bin -O $${soc}.bin && \
		chmod +x $${soc}.bin && ./$${soc}.bin --auto-accept && \
		mv $${soc}-demo-$(MCORE_VERSION) $${soc}-demo && \
		rm -f $${soc}.bin; \
	     done; \
         fi && \
	 $(call fbprint_d,"imx_mcore_demo")

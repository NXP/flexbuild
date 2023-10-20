# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# Sound Open Firmware
# https://www.sofproject.org"


imx_sof:
ifeq ($(SOCFAMILY), IMX)
	@[ $(DISTROVARIANT) = base -o $(DISTROVARIANT) = tiny ] && exit || \
	 $(call fbprint_b,"imx_sof") && \
	 if [ ! -d $(MMDIR)/imx_sof/sof-xcc ]; then \
	     mkdir -p $(MMDIR)/imx_sof && cd $(MMDIR)/imx_sof && \
	     wget -q $(repo_imx_sof_bin_url) -O imx_sof.tar.gz && \
	     tar xf imx_sof.tar.gz --strip-components 1; \
	 fi && \
	 \
	 cd $(MMDIR)/imx_sof && \
	 if [ ! -d $(RFSDIR)/usr/lib ]; then \
	     bld rfs -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 mkdir -p $(FBOUTDIR)/bsp/imx_firmware/lib/firmware/imx && \
	 cp -Prf sof* $(FBOUTDIR)/bsp/imx_firmware/lib/firmware/imx && \
	 $(call fbprint_d,"imx_sof")
endif

# Copyright 2017-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# Sound Open Firmware with Zephy
# https://www.sofproject.org"
# LICENSE: Apache-2.0 & BSD-3-Clause

sof_zephyr:
	@[ $(SOCFAMILY) != IMX -o $(DISTROVARIANT) != desktop ] && exit || \
	 if [ ! -d $(MMDIR)/sof_zephyr/sof-xcc ]; then \
	     mkdir -p $(MMDIR)/sof_zephyr && cd $(MMDIR)/sof_zephyr && \
	     wget -q $(repo_sof_zephyr_tar_url) -O sof_zephyr.tar.gz $(LOG_MUTE) && \
	     tar xf sof_zephyr.tar.gz --strip-components 1; \
	 fi && \
	 if [ ! -d $(RFSDIR)/usr/lib ]; then \
	     bld rfs -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 $(call fbprint_b,"sof_zephyr") && \
	 cd $(MMDIR)/sof_zephyr && \
	 rm -f sof_zephyr.tar.gz && \
	 mkdir -p $(FBOUTDIR)/bsp/imx_firmware/lib/firmware/imx && \
	 cp -Prf sof* $(FBOUTDIR)/bsp/imx_firmware/lib/firmware/imx && \
	 $(call fbprint_d,"sof_zephyr")

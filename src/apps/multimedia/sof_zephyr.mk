# Copyright 2017-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# Sound Open Firmware with Zephy
# https://www.sofproject.org"
# LICENSE: Apache-2.0 & BSD-3-Clause

sof_zephyr:
	@[ $(SOCFAMILY) != IMX ] && exit || \
	$(call dl_by_wget,sof_zephyr_tar,sof_zephyr.tar.gz) && \
	$(call fbprint_b,"sof_zephyr") && \
	if [ ! -d "$(MMDIR)"/sof_zephyr ]; then \
		mkdir -p $(DESTDIR)/lib/firmware/imx "$(MMDIR)"/sof_zephyr; \
		tar xf $(FBDIR)/dl/sof_zephyr.tar.gz --strip-components=1 --wildcards -C $(MMDIR)/sof_zephyr; \
	fi && \
	cd $(MMDIR)/sof_zephyr && \
	mkdir -p $(DESTDIR)/lib/firmware/imx && \
	cp -Prf sof* $(DESTDIR)/lib/firmware/imx && \
	if [[ "$(MACHINE)" == imx95* ]]; then \
		rm -f $(DESTDIR)/lib/firmware/imx/sof; \
		ln -sf sof-zephyr-gcc $(DESTDIR)/lib/firmware/imx/sof; \
	fi && \
	$(call fbprint_d,"sof_zephyr")

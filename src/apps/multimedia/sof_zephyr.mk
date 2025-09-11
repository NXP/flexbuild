# Copyright 2017-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# Sound Open Firmware with Zephy
# https://www.sofproject.org"
# LICENSE: Apache-2.0 & BSD-3-Clause

sof_zephyr:
	@[ $${MACHINE:0:5} != imx93 ] && exit || \
	if [ ! -f "$(FBDIR)"/dl/sof_zephyr.tar.gz ]; then \
		$(WGET) $(repo_sof_zephyr_tar_url) -O $(FBDIR)/dl/sof_zephyr.tar.gz $(LOG_MUTE); \
		[ $$? -ne 0 ] && { echo "Downloading $(repo_sof_zephyr_tar_url) failed."; exit 1; } || true; \
	fi && \
	$(call fbprint_b,"sof_zephyr") && \
	if [ ! -d "$(MMDIR)"/sof_zephyr ]; then \
		mkdir -p $(DESTDIR)/lib/firmware/imx "$(MMDIR)"/sof_zephyr; \
		tar xf $(FBDIR)/dl/sof_zephyr.tar.gz --strip-components=1 --wildcards -C $(MMDIR)/sof_zephyr; \
	fi && \
	cd $(MMDIR)/sof_zephyr && \
	cp -Prf sof* $(DESTDIR)/lib/firmware/imx && \
	$(call fbprint_d,"sof_zephyr")

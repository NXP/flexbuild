# Copyright 2021-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# A library to retrieve i.MX GPU performance data



libgpuperfcnt:
	@[ $${MACHINE:0:4} != imx8 ] && exit || \
	$(call dl_by_wget,libgpuperfcnt_bin,libgpuperfcnt.bin) && \
	cd $(GRAPHICSDIR) && \
	if [ ! -d "$(GRAPHICSDIR)"/libgpuperfcnt ]; then \
		chmod +x $(FBDIR)/dl/libgpuperfcnt.bin; \
		$(FBDIR)/dl/libgpuperfcnt.bin --auto-accept --force $(LOG_MUTE); \
		mv libgpuperfcnt-* libgpuperfcnt; \
	fi && \
	$(call fbprint_b,"libgpuperfcnt") && \
	cp -Prf libgpuperfcnt/usr $(DESTDIR) && \
	$(call fbprint_d,"libgpuperfcnt")

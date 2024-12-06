# Copyright 2021-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# A library to retrieve i.MX GPU performance data



libgpuperfcnt:
	@[ $(DISTROVARIANT) != desktop ] && exit || \
	 $(call fbprint_b,"libgpuperfcnt") && \
	 cd $(GRAPHICSDIR) && \
	 if [ ! -d libgpuperfcnt ]; then \
	     wget -q $(repo_libgpuperfcnt_bin_url) -O libgpuperfcnt.bin && \
	     chmod +x libgpuperfcnt.bin && ./libgpuperfcnt.bin --auto-accept && \
	     rm -f libgpuperfcnt.bin; \
	 fi && \
	 cp -Prf libgpuperfcnt/usr $(DESTDIR) && \
	 $(call fbprint_d,"libgpuperfcnt")

# Copyright 2021-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# A library to retrieve i.MX GPU performance data


libgpuperfcnt:
	@[ $(DESTARCH) != arm64 -o $(DISTROVARIANT) != desktop ] && exit || \
	 $(call fbprint_b,"libgpuperfcnt") && \
	 cd $(GRAPHICSDIR) && \
	 if [ ! -d libgpuperfcnt ]; then \
	     wget -q $(repo_libgpuperfcnt_bin_url) -O libgpuperfcnt.bin && \
	     chmod +x libgpuperfcnt.bin && ./libgpuperfcnt.bin --auto-accept && \
	     mv libgpuperfcnt-* libgpuperfcnt && rm -f libgpuperfcnt.bin; \
	 fi && \
	 cp -Prf libgpuperfcnt/usr $(DESTDIR) && \
	 $(call fbprint_d,"libgpuperfcnt")

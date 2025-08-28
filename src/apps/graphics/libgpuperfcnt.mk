# Copyright 2021-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# A library to retrieve i.MX GPU performance data



libgpuperfcnt:
	@[ $${MACHINE:0:4} != imx8 ] && exit || \
	 $(call fbprint_b,"libgpuperfcnt") && \
	 cd $(GRAPHICSDIR) && \
	 if [ ! -d libgpuperfcnt ]; then \
		 rm -rf libgpuperfcnt*; \
	     $(WGET) $(repo_libgpuperfcnt_bin_url) -O libgpuperfcnt.bin $(LOG_MUTE); \
		 [ $$? -ne 0 ] && { echo "Downloading $(repo_libgpuperfcnt_bin_url) failed."; exit 1; } || \
	     chmod +x libgpuperfcnt.bin && ./libgpuperfcnt.bin --auto-accept --force $(LOG_MUTE); \
	     mv libgpuperfcnt-* libgpuperfcnt && rm -f libgpuperfcnt.bin; \
	 fi && \
	 cp -Prf libgpuperfcnt/usr $(DESTDIR) && \
	 $(call fbprint_d,"libgpuperfcnt")

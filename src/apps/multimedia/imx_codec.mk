# Copyright 2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# iMX multimedia codec libs


imx_codec:
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) != desktop ] && exit || true && \
	 $(call fbprint_b,"imx_codec") && \
	 cd $(MMDIR) && \
	 if [ ! -d imx_codec ]; then \
	     wget -q $(repo_imx_codec_bin_url) -O imx_codec.bin && \
	     chmod +x imx_codec.bin && ./imx_codec.bin --auto-accept && \
	     mv imx-codec* imx_codec && rm -f imx_codec.bin; \
	 fi && \
	 cd imx_codec && \
	 sed -i '502,504s/FSL_USE_ALL_TRUE/FSL_USE_ALL_FALSE/' Makefile.in && \
	 ./configure CC=aarch64-linux-gnu-gcc \
	   --enable-armv8 \
	   --enable-all \
	   --prefix=/usr && \
	 $(MAKE) -j$(JOBS) && \
	 $(MAKE) install && \
	 rm -rf $(DESTDIR)/usr/share/imx-mm/*-codec/build $(DESTDIR)/usr/lib/imx-mm/video-codec && \
	 find $(DESTDIR)/usr/*/imx-mm -name *arm12* -o -name *arm11* -o -name *arm9* | xargs rm -f && \
	 $(call fbprint_d,"imx_codec")
endif

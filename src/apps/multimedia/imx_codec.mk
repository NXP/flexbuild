# Copyright 2021-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# iMX multimedia codec libs

# option --enable-vpu only for imx6q/imx6dl


imx_codec:
	@[ $(DISTROVARIANT) != desktop -o $(SOCFAMILY) != IMX ] && exit || \
	 $(call fbprint_b,"imx_codec") && \
	 cd $(MMDIR) && \
	 if [ ! -d imx_codec ]; then \
	     wget -q $(repo_imx_codec_bin_url) -O imx_codec.bin && \
	     chmod +x imx_codec.bin && ./imx_codec.bin --auto-accept && \
	     mv imx-codec* imx_codec && rm -f imx_codec.bin; \
	 fi && \
	 cd imx_codec && \
	 ./configure CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" \
	   --enable-armv8 \
	   --disable-static \
	   --disable-vpu \
	   --prefix=/usr && \
	 $(MAKE) -j$(JOBS) && \
	 $(MAKE) install && \
	 rm -rf $(DESTDIR)/usr/share/imx-mm/*-codec/build $(DESTDIR)/usr/lib/imx-mm/video-codec && \
	 find $(DESTDIR)/usr/*/imx-mm -name *arm12* -o -name *arm11* -o -name *arm9* | xargs rm -f && \
	 for p in lib_aac_dec_arm_elinux.so.3 lib_mp3_dec_arm_elinux.so.2 lib_oggvorbis_dec_arm_elinux.so.2; do \
	     cp -f $(DESTDIR)/usr/lib/imx-mm/audio-codec/$$p $(DESTDIR)/usr/lib/; \
	 done && \
	 $(call fbprint_d,"imx_codec")

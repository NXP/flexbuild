# Copyright 2021-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# iMX multimedia codec libs

# option --enable-vpu only for imx6q/imx6dl


imx_codec:
	@[ $(SOCFAMILY) != IMX ] && exit || \
	$(call dl_by_wget,imx_codec_bin,imx_codec.bin) && \
	cd $(MMDIR) && \
	if [ ! -d "$(MMDIR)"/imx_codec ]; then \
		chmod +x $(FBDIR)/dl/imx_codec.bin; \
		$(FBDIR)/dl/imx_codec.bin --auto-accept --force $(LOG_MUTE); \
		mv imx-codec* imx_codec; \
	fi && \
	$(call fbprint_b,"imx_codec") && \
	cd imx_codec && \
	./configure CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" \
	   --enable-armv8 \
	   --disable-static \
	   --disable-vpu \
	   --prefix=/usr $(LOG_MUTE) && \
	$(MAKE) -j$(JOBS) $(LOG_MUTE) && \
	$(MAKE) install $(LOG_MUTE) && \
	rm -rf $(DESTDIR)/usr/share/imx-mm/*-codec/build $(DESTDIR)/usr/lib/imx-mm/video-codec && \
	find $(DESTDIR)/usr/*/imx-mm -name *arm12* -o -name *arm11* -o -name *arm9* | xargs rm -f && \
	for p in lib_aac_dec_arm_elinux.so.3 lib_mp3_dec_arm_elinux.so.2 lib_oggvorbis_dec_arm_elinux.so.2; do \
	    cp -f $(DESTDIR)/usr/lib/imx-mm/audio-codec/$$p $(DESTDIR)/usr/lib/; \
	done && \
	$(call fbprint_d,"imx_codec")

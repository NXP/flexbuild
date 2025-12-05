# Copyright 2025 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


#neo_ipa_uguzzi:
neo_ipa_uguzzi: libcamera
	@[ $${MACHINE:0:5} != imx95 ] && exit || \
	 $(call download_repo,neo_ipa_uguzzi,apps/multimedia) && \
	 $(call patch_apply,neo_ipa_uguzzi,apps/multimedia) && \
	 $(call fbprint_b,"neo_ipa_uguzzi") && \
	 cd $(MMDIR)/neo_ipa_uguzzi && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     -e 's%@DESTDIR@%$(DESTDIR)%g' $(FBDIR)/src/system/meson.cross > meson.cross && \
	 rm -rf build && \
	 export C_INCLUDE_PATH="$(DESTDIR)/usr/include/libcamera:$${C_INCLUDE_PATH}" && \
	 export CPLUS_INCLUDE_PATH="$(DESTDIR)/usr/include/libcamera:$${CPLUS_INCLUDE_PATH}" && \
	 meson setup build \
		-Dc_link_args="-L$(DESTDIR)/usr/lib" \
		-Dcpp_link_args="-L$(DESTDIR)/usr/lib" \
		--prefix=/usr --buildtype=plain \
		--cross-file meson.cross \
		--libdir=lib \
		--wrap-mode=nodownload $(LOG_MUTE) && \
	 ninja -j $(JOBS) -C build install -v $(LOG_MUTE) && \
	 $(call fbprint_d,"neo_ipa_uguzzi")

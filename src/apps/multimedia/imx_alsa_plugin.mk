# Copyright 2021-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# depends on libasound2 and libasound2-dev

imx_alsa_plugin:
	@[ $(DESTARCH) != arm64 -o $(DISTROVARIANT) != desktop ] && exit || \
	 $(call fbprint_b,"imx_alsa_plugin") && \
	 $(call repo-mngr,fetch,imx_alsa_plugin,apps/multimedia) && \
	 if  [ ! -f $(DESTDIR)/usr/lib/pkgconfig/alsa.pc ]; then \
	     bld alsa_lib -r $(DISTROTYPE):$(DISTROVARIANT) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/include/imx-mm/audio-codec/swpdm/imx-swpdm.h ]; then \
	     bld imx_sw_pdm -r $(DISTROTYPE):$(DISTROVARIANT) -f $(CFGLISTYML); \
	 fi && \
	 sudo cp -rf $(DESTDIR)/usr/include/imx-mm $(RFSDIR)/usr/include && \
	 sudo ln -sf libasound.so.2 $(RFSDIR)/usr/lib/aarch64-linux-gnu/libasound.so && \
	 \
	 cd $(MMDIR)/imx_alsa_plugin && \
	 sed -i 's/imx\///' asrc/asrc_pair.h asrc/asrc_pair.c && \
	 libtoolize --force --copy --automake && \
	 aclocal && autoheader && \
	 automake --foreign --copy --add-missing && \
	 touch depcomp && autoconf && \
	 ./configure --host=aarch64 CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" \
	   --with-libtool-sysroot=$(RFSDIR) \
	   --disable-silent-rules --disable-static --enable-swpdm \
	   CFLAGS="-O2 -Wall -W -pipe -g -I$(DESTDIR)/usr/include" 1>/dev/null && \
	 $(MAKE) install && \
	 $(call fbprint_d,"imx_alsa_plugin")

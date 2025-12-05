# Copyright 2021-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# depends on libasound2 and libasound2-dev

imx_alsa_plugin: alsa_lib imx_sw_pdm
	@[ $(SOCFAMILY) != IMX ] && exit || \
	 $(call download_repo,imx_alsa_plugin,apps/multimedia) && \
	 $(call patch_apply,imx_alsa_plugin,apps/multimedia) && \
	 sudo cp -rf $(DESTDIR)/usr/include/imx-mm $(RFSDIR)/usr/include && \
	 sudo ln -sf libasound.so.2 $(RFSDIR)/usr/lib/aarch64-linux-gnu/libasound.so && \
	 \
	 $(call fbprint_b,"imx_alsa_plugin") && \
	 cd $(MMDIR)/imx_alsa_plugin && \
	 sed -i 's/imx\///' asrc/asrc_pair.h asrc/asrc_pair.c && \
	 libtoolize --force --copy --automake && \
	 aclocal $(LOG_MUTE) && autoheader $(LOG_MUTE) && \
	 automake --foreign --copy --add-missing $(LOG_MUTE) && \
	 touch depcomp && autoconf $(LOG_MUTE) && \
	 ./configure --host=aarch64 CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" \
	   --with-libtool-sysroot=$(RFSDIR) \
	   --disable-silent-rules --disable-static --enable-swpdm \
	   CFLAGS="-O2 -Wall -W -pipe -g -I$(DESTDIR)/usr/include" $(LOG_MUTE) && \
	 $(MAKE) install $(LOG_MUTE) && \
	 $(call fbprint_d,"imx_alsa_plugin")

# Copyright 2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# NXP i.MX alsa-lib plugin


imx_alsa_plugin:
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) != desktop ] && exit || \
	 $(call fbprint_b,"imx_alsa_plugin") && \
	 $(call repo-mngr,fetch,imx_alsa_plugin,apps/multimedia) && \
	 if [ ! -f $(DESTDIR)/usr/include/imx/linux/mxc_asrc.h ]; then \
	     bld -c imx_vpu -r $(DISTROTYPE):$(DISTROSCALE) -f $(CFGLISTYML); \
	 fi && \
	 if  [ ! -f $(DESTDIR)/usr/lib/pkgconfig/alsa.pc ]; then \
	     bld -c alsa_lib -r $(DISTROTYPE):$(DISTROSCALE) -f $(CFGLISTYML); \
	 fi && \
	 export PKG_CONFIG_PATH=$(DESTDIR)/usr/lib/pkgconfig && \
	 cd $(MMDIR)/imx_alsa_plugin && \
	 libtoolize --force --copy --automake && \
	 aclocal $(ACLOCAL_FLAGS) && autoheader && \
	 automake --foreign --copy --add-missing && \
	 touch depcomp && autoconf && \
	 ./configure --host=aarch64 CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" \
	   CFLAGS="-O2 -Wall -W -pipe -g -I$(DESTDIR)/usr/include/imx" 1>/dev/null && \
	 $(MAKE) install && \
	 $(call fbprint_d,"imx_alsa_plugin")
endif

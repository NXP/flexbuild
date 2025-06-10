# Copyright 2023-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# Unit tests for the i.MX BSP


PLATFORM = IMX8

imx_test: libdrm alsa_lib
	@[ $(DESTARCH) != arm64 -o $(SOCFAMILY) != IMX -o $(DISTROVARIANT) != desktop ] && exit || \
	 $(call repo-mngr,fetch,imx_test,apps/utils) && \
	 if [ ! -f $(DESTDIR)/usr/include/linux/mxc_asrc.h ]; then \
	     bld linux-headers -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/include/xf86drm.h ]; then \
	     bld libdrm -r $(DISTROTYPE):$(DISTROVARIANT); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/include/alsa/asoundlib.h ]; then \
	     bld alsa_lib -r $(DISTROTYPE):$(DISTROVARIANT); \
	 fi && \
	 sudo cp -rf $(DESTDIR)/usr/include/alsa $(RFSDIR)/usr/include && \
	 $(call fbprint_b,"imx_test") && \
	 cd $(UTILSDIR)/imx_test && \
	 mkdir -p $(DESTDIR)/opt/unit_tests && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR) -I$(RFSDIR)/usr/include -I$(DESTDIR)/usr/include -O2 -pipe -g" && \
	 V=0 VERBOSE='' SDKTARGETSYSROOT=$(DESTDIR) PLATFORM=$(PLATFORM) \
	 $(MAKE) -j$(JOBS) $(LOG_MUTE) && \
	 $(MAKE) install DESTDIR=$(DESTDIR)/opt/unit_tests PLATFORM=$(PLATFORM) $(LOG_MUTE) && \
	 $(call fbprint_d,"imx_test")

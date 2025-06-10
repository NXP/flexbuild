# Copyright 2025 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# section: iMX multimedia
# description: NXP Audio Front End (AFE) for incorporating Voice Assistants

nxp_afe:
ifeq ($(CONFIG_NXP_AFE),y)
	@[ $(DISTROVARIANT) != desktop -o $(SOCFAMILY) != IMX ] && exit || \
	 $(call repo-mngr,fetch,nxp_afe,apps/multimedia) && \
	 if  [ ! -f $(DESTDIR)/usr/lib/pkgconfig/alsa.pc ]; then \
	     bld alsa_lib -r $(DISTROTYPE):$(DISTROVARIANT); \
	 fi && \
	 [ -f $(DESTDIR)/unit_tests/nxp-afe ] && exit || \
	 $(call fbprint_b,"nxp_afe") && \
	 cd $(MMDIR)/nxp_afe && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)" && \
	 export INSTALLDIR=$(MMDIR)/nxp_afe/deploy_afe && \
	 sed -i '/^INSTALLDIR/c INSTALLDIR := ./deploy_afe' makefile && \
	 \
	 $(MAKE) clean && \
	 $(MAKE) -j$(JOBS) all $(LOG_MUTE) && \
	 \
	 install -d $(DESTDIR)/usr/lib/nxp-afe && \
	 install -d $(DESTDIR)/unit_tests/nxp-afe && \
	 install -m 0644 deploy_afe/*.so.1.0 $(DESTDIR)/usr/lib/nxp-afe && \
	 ln -sf -r $(DESTDIR)/usr/lib/nxp-afe/libdummyimpl.so.1.0 $(DESTDIR)/usr/lib/nxp-afe/libdummyimpl.so && \
	 install -m 0755 deploy_afe/afe $(DESTDIR)/unit_tests/nxp-afe && \
	 install -m 0644 deploy_afe/asound.conf*    $(DESTDIR)/unit_tests/nxp-afe && \
	 install -m 0644 deploy_afe/TODO.md    $(DESTDIR)/unit_tests/nxp-afe && \
	 install -m 0755 deploy_afe/UAC_VCOM_composite.sh  $(DESTDIR)/unit_tests/nxp-afe && \
	 \
	 $(call fbprint_d,"imx_afe")
endif

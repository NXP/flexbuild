# Copyright 2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# i.MX HANTRO V4L2 Daemon


imx_vpu_hantro_daemon:
ifeq ($(CONFIG_IMX_VPU), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) != desktop ] && exit || \
	 $(call fbprint_b,"imx_vpu_hantro_daemon") && \
	 if [ ! -d $(MMDIR)/imx_vpu_hantro_daemon ]; then \
	     cd $(MMDIR) && wget -q $(repo_vpu_hantro_daemon_tar_url) -O imx_vpu_hantro_daemon.tar.gz && \
	     tar xf imx_vpu_hantro_daemon.tar.gz && rm -rf imx_vpu_hantro_daemon.tar.gz && \
	     mv imx-vpu-hantro-daemon-* imx_vpu_hantro_daemon; \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/libhantro.so ]; then \
	     bld -c imx_vpu -r $(DISTROTYPE):$(DISTROSCALE) -p $(SOCFAMILY) -f $(CFGLISTYML); \
	 fi && \
	 cd $(MMDIR)/imx_vpu_hantro_daemon && \
	 sed -e 's|HANTRO_VC8000E_LIB_DIR =.*|HANTRO_VC8000E_LIB_DIR = $(DESTDIR)/usr/lib|' \
	     -e 's|HANTRO_G1G2_LIB_DIR =.*|HANTRO_G1G2_LIB_DIR = $(DESTDIR)/usr/lib|' -i Makefile && \
	 $(MAKE) SDKTARGETSYSROOT=$(RFSDIR) DEST_DIR=$(DESTDIR) CTRLSW_HDRPATH="$(DESTDIR)/usr/include" && \
	 $(MAKE) SDKTARGETSYSROOT=$(RFSDIR) DEST_DIR=$(DESTDIR) install && \
	 $(call fbprint_d,"imx_vpu_hantro_daemon")
endif
endif

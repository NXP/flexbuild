# Copyright 2021-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# i.MX VPU HANTRO V4L2 Daemon for IMX8MM, IMX8MP, IMX8MQ

# /usr/bin/vsidaemon
# for 8mm (845): -lhantro -lg1 -lhantro_h1
# for 8mq (850): -lhantro -lg1
# for 8mp (865): -lhantro -lg1 -lhantro_vc8000e

SOCLIST = IMX8MM IMX8MQ IMX8MP

imx_vpu_hantro_daemon:
	@[ $(DISTROVARIANT) != desktop -o $(SOCFAMILY) != IMX ] && exit || \
	 $(call fbprint_b,"imx_vpu_hantro_daemon") && \
	 if [ ! -d $(MMDIR)/imx_vpu_hantro_daemon ]; then \
	     cd $(MMDIR) && wget -q $(repo_vpu_hantro_daemon_tar_url) -O imx_vpu_hantro_daemon.tar.gz && \
	     tar xf imx_vpu_hantro_daemon.tar.gz && rm -rf imx_vpu_hantro_daemon.tar.gz && \
	     mv imx-vpu-hantro-daemon-* imx_vpu_hantro_daemon; \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/libhantro.so ]; then \
	     bld imx_vpu_hantro -r $(DISTROTYPE):$(DISTROVARIANT) -p $(SOCFAMILY) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/include/hantro_VC8000E_enc/ewl.h ]; then \
	     bld imx_vpu_hantro_vc -r $(DISTROTYPE):$(DISTROVARIANT) -p $(SOCFAMILY) -f $(CFGLISTYML); \
	 fi && \
	 cd $(MMDIR)/imx_vpu_hantro_daemon && \
	 sed -e 's|HANTRO_VC8000E_LIB_DIR =.*|HANTRO_VC8000E_LIB_DIR = $(DESTDIR)/usr/lib|' \
	     -e 's|HANTRO_G1G2_LIB_DIR =.*|HANTRO_G1G2_LIB_DIR = $(DESTDIR)/usr/lib|' \
	     -e 's|HANTRO_H1_LIB_DIR =.*|HANTRO_H1_LIB_DIR = $(DESTDIR)/usr/lib|' \
	     -e 's|CTRLSW_HDRPATH =.*|CTRLSW_HDRPATH = $(DESTDIR)/usr/include|' -i Makefile && \
	 for socplat in $(SOCLIST); do \
	     $(MAKE) clean && \
	     $(MAKE) SDKTARGETSYSROOT=$(DESTDIR) DEST_DIR=$(DESTDIR) PLATFORM=$$socplat && \
	     $(MAKE) SDKTARGETSYSROOT=$(DESTDIR) DEST_DIR=$(DESTDIR) PLATFORM=$$socplat install && \
	     mv $(DESTDIR)/usr/bin/vsidaemon $(DESTDIR)/usr/bin/vsidaemon-$$socplat; \
	 done && \
	 $(call fbprint_d,"imx_vpu_hantro_daemon")

# Copyright 2021-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# i.MX VPU HANTRO V4L2 Daemon for IMX8MM, IMX8MP, IMX8MQ

# /usr/bin/vsidaemon
# for 8mm (845): -lhantro -lg1 -lhantro_h1
# for 8mq (850): -lhantro -lg1
# for 8mp (865): -lhantro -lg1 -lhantro_vc8000e

SOCLIST = IMX8MM IMX8MQ IMX8MP

imx_vpu_hantro_daemon: imx_vpu_hantro imx_vpu_hantro_vc
	@[ $(SOCFAMILY) != IMX ] && exit || \
	$(call dl_by_wget,vpu_hantro_daemon_tar,imx_vpu_hantro_daemon.tar.gz) && \
	cd $(MMDIR) && \
	if [ ! -d "$(MMDIR)"/imx_vpu_hantro_daemon ]; then \
		mkdir -p "$(MMDIR)"/imx_vpu_hantro_daemon; \
		tar xf $(FBDIR)/dl/imx_vpu_hantro_daemon.tar.gz --strip-components=1 --wildcards -C $(MMDIR)/imx_vpu_hantro_daemon; \
	fi && \
	$(call fbprint_b,"imx_vpu_hantro_daemon") && \
	cd $(MMDIR)/imx_vpu_hantro_daemon && \
	sed -e 's|HANTRO_VC8000E_LIB_DIR =.*|HANTRO_VC8000E_LIB_DIR = $(DESTDIR)/usr/lib|' \
	     -e 's|HANTRO_G1G2_LIB_DIR =.*|HANTRO_G1G2_LIB_DIR = $(DESTDIR)/usr/lib|' \
	     -e 's|HANTRO_H1_LIB_DIR =.*|HANTRO_H1_LIB_DIR = $(DESTDIR)/usr/lib|' \
	     -e 's|CTRLSW_HDRPATH =.*|CTRLSW_HDRPATH = $(DESTDIR)/usr/include|' -i Makefile && \
	for socplat in $(SOCLIST); do \
	     $(MAKE) clean && \
	     $(MAKE) SDKTARGETSYSROOT=$(RFSDIR) DEST_DIR=$(DESTDIR) PLATFORM=$$socplat $(LOG_MUTE) && \
	     $(MAKE) SDKTARGETSYSROOT=$(RFSDIR) DEST_DIR=$(DESTDIR) PLATFORM=$$socplat install $(LOG_MUTE) && \
	     mv $(DESTDIR)/usr/bin/vsidaemon $(DESTDIR)/usr/bin/vsidaemon-$$socplat; \
	done && \
	$(call fbprint_d,"imx_vpu_hantro_daemon")

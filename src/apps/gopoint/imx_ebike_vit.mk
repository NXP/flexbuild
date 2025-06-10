# Copyright 2025 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

GPNT_APPS_FOLDER = /opt/gopoint-apps
EBIKE_DIR = ${GPNT_APPS_FOLDER}/scripts/multimedia/ebike-vit

imx_ebike_vit:
	@[ $(SOCFAMILY) != IMX -o $(DISTROVARIANT) != desktop ] && exit || \
	 $(call repo-mngr,fetch,imx_ebike_vit,apps/gopoint) && \
#	 if  [ ! -f $(DESTDIR)/usr/lib/nxp-afe/libdummyimpl.so.1.0 ]; then \
#	     bld nxp_afe -r $(DISTROTYPE):$(DISTROVARIANT); \
#	 fi && \
#	 if [[ ! -f $(DESTDIR)/usr/lib/nxp-afe/libvoiceseekerlight.so.2.0 ]]; then \
#	     bld imx_voiceui -r $(DISTROTYPE):$(DISTROVARIANT); \
#	 fi && \
	 \
	 $(call fbprint_b,"imx_ebike_vit") && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)" && \
	 cd $(GPDIR)/imx_ebike_vit && \
	 if [ -d $(FBDIR)/patch/imx_ebike_vit ] && [ ! -f .patchdone ]; then \
		 git am $(FBDIR)/patch/imx_ebike_vit/*.patch && touch .patchdone; \
	 fi && \
	 if [ ! -f lvgl/.codedone ]; then \
	 	 git submodule update --init --recursive && touch lvgl/.codedone; \
		 cp -fr wayland-client/* lv_drivers/wayland/ ; \
	 fi && \
	 \
	 $(MAKE) clean && $(MAKE) -j$(JOBS) $(LOG_MUTE) && \
	 install -d -m 755 $(DESTDIR)$(EBIKE_DIR) && \
	 cp -rf ebike-vit-deploy/* $(DESTDIR)$(EBIKE_DIR) && \
	 $(call fbprint_d,"imx_ebike_vit")

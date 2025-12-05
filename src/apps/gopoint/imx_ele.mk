# Copyright 2025 NXP
#
# SPDX-License-Identifier: BSD-3-Clause





GPNT_APPS_FOLDER = /opt/gopoint-apps

#imx_ele:
imx_ele: imx_secure_enclave
	@[ $${MACHINE:0:5} != imx93 ] && exit || \
	 $(call download_repo,imx_ele,apps/gopoint,git) && \
	 \
	 $(call fbprint_b,"imx_ele") && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)" && \
	 export ELE_ROOT=$(PKGDIR)/apps/security/imx_secure_enclave && \
	 \
	 cd $(GPDIR)/imx_ele/lv_drivers && \
	 if [ -d $(FBDIR)/patch/imx_ele ] && [ ! -f .patchdone ]; then \
		 git apply $(FBDIR)/patch/imx_ele/*.patch && touch .patchdone; \
	 fi && \
	 cd $(GPDIR)/imx_ele && \
	 cp -rf protocols/ lv_drivers/wayland/ && \
	 \
	 $(MAKE) clean && $(MAKE) -j$(JOBS) $(LOG_MUTE) && \
	 install -d -m 755 $(DESTDIR)/$(GPNT_APPS_FOLDER)/scripts/security/ele && \
	 $(CROSS_COMPILE)strip $(GPDIR)/imx_ele/bin/eledemo && \
	 cp -rf $(GPDIR)/imx_ele/bin/eledemo $(DESTDIR)/$(GPNT_APPS_FOLDER)/scripts/security/ele && \
	 cp -rf $(GPDIR)/imx_ele/misc/script/run.sh $(DESTDIR)/$(GPNT_APPS_FOLDER)/scripts/security/ele && \
	 $(call fbprint_d,"imx_ele")

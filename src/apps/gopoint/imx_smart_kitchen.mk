# Copyright 2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

GPNT_APPS_FOLDER = /opt/gopoint-apps

imx_smart_kitchen:
	@[ $(SOCFAMILY) != IMX -o $(DISTROVARIANT) != desktop ] && exit || \
	 $(call fbprint_b,"imx_smart_kitchen") && \
	 $(call repo-mngr,fetch,imx_smart_kitchen,apps/gopoint) && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)" && \
	 cd $(GPDIR)/imx_smart_kitchen && \
         if [ -d $(FBDIR)/patch/imx_smart_kitchen ] && [ ! -f .patchdone ]; then \
             git am $(FBDIR)/patch/imx_smart_kitchen/*.patch && touch .patchdone; \
         fi && \
	 sed -i 's|/home/root/.nxp-demo-experience|/opt/gopoint-apps|g' \
	     main.cpp main.cpp misc/scripts/vit-notify/WWCommandNotify && \
	 if [ ! -f lvgl/.patchdone ]; then \
	     cp misc/patches/*.patch lvgl/ && \
	     cp -r wayland-client/* lv_drivers/wayland/ && \
	     cd lvgl && git am *.patch && touch .patchdone && cd ..; \
	 fi && \
	 rm -rf smart-kitchen-deploy && \
	 $(MAKE) -j$(JOBS) && \
	 install -d -m 755 $(DESTDIR)$(GPNT_APPS_FOLDER)/scripts/multimedia/smart-kitchen && \
	 cp -rf smart-kitchen-deploy/* $(DESTDIR)$(GPNT_APPS_FOLDER)/scripts/multimedia/smart-kitchen && \
	$(call fbprint_d,"imx_smart_kitchen")

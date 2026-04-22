# Copyright 2025-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

EBIKE_DIR = ${GPNT_APPS_FOLDER}/scripts/multimedia/ebike-vit

imx_ebike_vit:
	@$(call download_repo,imx_ebike_vit,apps/gopoint,git)
	 $(call patch_apply,imx_ebike_vit,apps/gopoint)
	 $(call fbprint_b,"imx_ebike_vit")
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)"
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)"
	 cd $(GPDIR)/imx_ebike_vit
	 if [ -d $(FBDIR)/patch/imx_ebike_vit ] && [ ! -f .patchdone ]; then
		 git am $(FBDIR)/patch/imx_ebike_vit/*.patch && touch .patchdone
	 fi
	 if [ ! -f lvgl/.codedone ]; then
		git submodule update --init --recursive && touch lvgl/.codedone
		mkdir -p lv_drivers/wayland
		cp -af wayland-client/* lv_drivers/wayland/
	 fi
	 $(MAKE) clean $(LOG_MUTE) && $(MAKE) $(LOG_MUTE)
	 install -d -m 755 $(DESTDIR)$(EBIKE_DIR)
	 cp -af ebike-vit-deploy/* $(DESTDIR)$(EBIKE_DIR)/
	 $(call fbprint_d,"imx_ebike_vit")

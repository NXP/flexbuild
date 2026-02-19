#
# Copyright 2017-2023,2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


KOUTDIR := $(KERNEL_OUTPUT_PATH)/$(KERNEL_BRANCH)
KTGT_DIR := $(FBOUTDIR)/linux/$(KERNEL_TREE)/arm64/$(SOCFAMILY)
DTBSTR := $(if $(filter y,$(CONFIG_PLATFORM_IMX)),imx*.dtb,fsl*.dtb)
KERNEL_IMAGE := $(KTGT_DIR)/Image

define kernel_pre
	@$(call download_repo,linux,linux)
	$(call patch_apply,linux,linux)
	$(call fbprint_b,"$(KERNEL_TREE) with $(KERNEL_BRANCH)")
	mkdir -p $(KOUTDIR)/tmp
	if [ -f "$(FBDIR)/configs/linux/$(CONFIG_LINUX_EXTRA_CONFIG)" ]; then \
		cp -f "$(FBDIR)/configs/linux/$(CONFIG_LINUX_EXTRA_CONFIG)" $(KERNEL_PATH)/arch/arm64/configs/
	fi
	$(call fbprint_n,"Total Config List = $(KERNEL_CFG) $(CONFIG_LINUX_EXTRA_CONFIG)")
	if [ ! -f $(KOUTDIR)/.config ]; then \
	    $(MAKE) $(KERNEL_CFG) $(CONFIG_LINUX_EXTRA_CONFIG) -C $(KERNEL_PATH) O=$(KOUTDIR) 1>/dev/null 2>&1
	fi

endef

kernel-menuconfig linux-menuconfig:
	@$(call kernel_pre)
	$(MAKE) menuconfig -C $(KERNEL_PATH) O=$(KOUTDIR)
	$(call FB_OUT,The kernel configuration is complete. Please run 'make linux' to compile the kernel)

linux $(KERNEL_IMAGE):
	@$(call kernel_pre)
	$(MAKE) all -C $(KERNEL_PATH) O=$(KOUTDIR) $(LOG_MUTE)
	$(MAKE) zinstall INSTALL_PATH=$(KTGT_DIR) -C $(KERNEL_PATH) O=$(KOUTDIR) $(LOG_MUTE)
	cp $(KOUTDIR)/arch/arm64/boot/Image* $(KTGT_DIR)
	\
	$(MAKE) modules -C $(KERNEL_PATH) O=$(KOUTDIR) $(LOG_MUTE)
	$(MAKE) modules_install INSTALL_MOD_PATH=$(KOUTDIR)/tmp -C $(KERNEL_PATH) O=$(KOUTDIR) $(LOG_MUTE)
	cp $(KOUTDIR)/arch/arm64/boot/dts/freescale/$(DTBSTR) $(KTGT_DIR)
	$(call fbprint_d,"$(KERNEL_TREE) $(KERNEL_BRANCH) in $(KTGT_DIR)")



cryptodev_linux mdio_proxy_module isp_vvcam_module nxp_wlan_bt: $(KERNEL_IMAGE)
linux-modules: cryptodev_linux mdio_proxy_module isp_vvcam_module nxp_wlan_bt
	@$(call fbprint_d,"linux-modules")



linux-headers: $(KERNEL_IMAGE)
	@$(call download_repo,linux,linux)
	 mkdir -p $(DESTDIR)/usr
	 $(MAKE) headers_install INSTALL_HDR_PATH=$(DESTDIR)/usr -C $(KERNEL_PATH) O=$(KOUTDIR) $(LOG_MUTE)
	 $(call fbprint_d,"linux-headers")

# ------------------------------
# Build Debian kernel packages
# ------------------------------
linux-deb: linux
	@$(call fbprint_b,linux debian packages)
	mkdebian_file=$(PKGDIR)/linux/linux/scripts/package/mkdebian
	if [ -f $$mkdebian_file ]; then \
		sed -i '/^ libssl-dev:native,/ s/, libssl-dev.*/,/' $$mkdebian_file; \
	fi
	$(MAKE) bindeb-pkg -C $(KERNEL_PATH) O=$(KOUTDIR) $(LOG_MUTE)
	mkdir -p $(FBOUTDIR)/images
	cp -f $(KERNEL_OUTPUT_PATH)/*.deb $(FBOUTDIR)/images/
	$(call fbprint_d,"linux-deb in: $(FBOUTDIR)/images")

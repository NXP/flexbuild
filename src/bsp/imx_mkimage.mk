# Copyright 2020-2024,2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


UTILSDIR = $(PKGDIR)/apps/utils

define dl_imx_seco
	if [ ! -d $(BSPDIR)/imx-seco/firmware/seco ]; then
		cd $(BSPDIR) && $(call dl_by_wget,seco_bin,imx-seco.bin) && chmod +x $(FBDIR)/dl/imx-seco.bin
		$(FBDIR)/dl/imx-seco.bin --auto-accept --force $(LOG_MUTE) && mv `basename -s .bin $(repo_seco_bin_url)` imx-seco
	fi
endef

define dl_fw_ele
    if [ ! -d $(BSPDIR)/fw_ele ]; then
		cd $(BSPDIR) && $(call dl_by_wget,fw_ele_bin,fw_ele.bin) && chmod +x $(FBDIR)/dl/fw_ele.bin
		$(FBDIR)/dl/fw_ele.bin --auto-accept --force $(LOG_MUTE) && mv `basename -s .bin $(repo_fw_ele_bin_url)` fw_ele
    fi
endef

define dl_fw_upower
    if [ ! -d $(BSPDIR)/fw_upower ]; then
		cd $(BSPDIR) && $(call dl_by_wget,fw_upower_bin,fw_upower.bin) && chmod +x $(FBDIR)/dl/fw_upower.bin
		$(FBDIR)/dl/fw_upower.bin --auto-accept --force $(LOG_MUTE) && mv `basename -s .bin $(repo_fw_upower_bin_url)` fw_upower
    fi
endef

define dl_imx_scfw
    if [ ! -d $(BSPDIR)/imx-scfw ]; then
		cd $(BSPDIR) && $(call dl_by_wget,scfw_bin,imx-scfw.bin) && chmod +x $(FBDIR)/dl/imx-scfw.bin
		$(FBDIR)/dl/imx-scfw.bin --auto-accept --force $(LOG_MUTE) && mv `basename -s .bin $(repo_scfw_bin_url)` imx-scfw
    fi
endef

# Define common paths
UBOOT_OUT_DIR   = $(FBOUTDIR)/bsp/u-boot/$(MACHINE)/output/$(uboot_cfg)
IMX_MKIMAGE_DIR := $(BSPDIR)/imx_mkimage
BL32_BIN        = $(PKGDIR)/apps/security/optee_os/out/arm-plat-imx/core/tee_$(MACHINE).bin

# --- i.MX 8M Family (8MM, 8MP, 8MP-FRDM) ---
ifdef CONFIG_SOC_IMX8M
define build_soc_recipe
	@echo "Building flash.bin for iMX8M family $(ATF_OPTINFO)"
	$(eval IMX8MDIR := $(IMX_MKIMAGE_DIR)/iMX8M)
	cp -f $(UBOOT_OUT_DIR)/tools/mkimage $(IMX8MDIR)/mkimage_uboot
	cp -f $(UBOOT_OUT_DIR)/spl/u-boot-spl.bin $(UBOOT_OUT_DIR)/u-boot-nodtb.bin $(IMX8MDIR)/
	cp -f $(UTILSDIR)/firmware_imx/firmware/hdmi/cadence/signed*_imx8m.bin $(IMX8MDIR)/
	cp -f $(UTILSDIR)/firmware_imx/firmware/ddr/synopsys/*.bin $(IMX8MDIR)/
	cp -f $(BSPDIR)/atf/build/$(if $(CONFIG_SOC_IMX8MMEVK),imx8mm,imx8mp)/release/bl31.bin $(IMX8MDIR)/
	$(if $(CONFIG_OPTEE),cp -f $(BL32_BIN) $(IMX8MDIR)/tee.bin)
	@# DTB handling and renaming for FRDM
	$(if $(CONFIG_SOC_IMX8MMEVK), cp -f $(UBOOT_OUT_DIR)/dts/upstream/src/arm64/freescale/imx8mm-evk.dtb $(IMX8MDIR)/)
	$(if $(CONFIG_SOC_IMX8MPEVK), cp -f $(UBOOT_OUT_DIR)/dts/upstream/src/arm64/freescale/imx8mp-evk.dtb $(IMX8MDIR)/)
	$(if $(CONFIG_SOC_IMX8MPFRDM),cp -f $(UBOOT_OUT_DIR)/arch/arm/dts/imx8mp-frdm.dtb $(IMX8MDIR)/imx8mp-evk.dtb)
	cd $(IMX_MKIMAGE_DIR) && $(MAKE) SOC=$(if $(CONFIG_SOC_IMX8MMEVK),iMX8MM,iMX8MP) flash_evk $(LOG_MUTE)
	cp $(IMX8MDIR)/flash.bin $(FBOUTDIR)/images/$(MACHINE)-sd-flash.bin
endef
endif

# --- i.MX 8QM Family ---
ifdef CONFIG_SOC_IMX8QMMEK
define build_soc_recipe
	@echo "Building flash.bin for iMX8QM $(ATF_OPTINFO)"
	$(call dl_imx_scfw)
	$(call dl_imx_seco)
	cp -f $(UBOOT_OUT_DIR)/u-boot.bin $(UBOOT_OUT_DIR)/spl/u-boot-spl.bin $(IMX_MKIMAGE_DIR)/iMX8QM/
	cp -f $(BSPDIR)/imx-scfw/mx8qm-mek-scfw-tcm.bin $(IMX_MKIMAGE_DIR)/iMX8QM/scfw_tcm.bin
	cp -f $(BSPDIR)/atf/build/imx8qm/release/bl31.bin $(IMX_MKIMAGE_DIR)/iMX8QM/
	cp -f $(BSPDIR)/imx-seco/firmware/seco/mx8qmb0-ahab-container.img $(IMX_MKIMAGE_DIR)/iMX8QM/
	$(if $(CONFIG_OPTEE),cp -f $(BL32_BIN) $(IMX_MKIMAGE_DIR)/iMX8QM/tee.bin)
	cd $(IMX_MKIMAGE_DIR) && $(MAKE) SOC=iMX8QM $(if $(CONFIG_OPTEE),flash_spl,flash) $(LOG_MUTE)
	cp $(IMX_MKIMAGE_DIR)/iMX8QM/flash.bin $(FBOUTDIR)/images/$(MACHINE)-sd-flash.bin
endef
endif

# --- i.MX 91 Family ---
ifdef CONFIG_SOC_IMX91
define build_soc_recipe
	@echo "Building flash.bin for iMX91 $(ATF_OPTINFO)"
	$(call dl_fw_ele)
	$(eval IMX91DIR := $(IMX_MKIMAGE_DIR)/iMX91)
	cp -f $(UBOOT_OUT_DIR)/spl/u-boot-spl.bin $(UBOOT_OUT_DIR)/u-boot.bin $(IMX91DIR)/
	cp -f $(BSPDIR)/atf/build/imx91/release/bl31.bin $(IMX91DIR)/
	cp -f $(BSPDIR)/fw_ele/mx91a*-ahab-container.img $(IMX91DIR)/
	cp -f $(UTILSDIR)/firmware_imx/firmware/ddr/synopsys/*.bin $(IMX91DIR)/
	$(if $(CONFIG_OPTEE),cp -f $(BL32_BIN) $(IMX91DIR)/tee.bin)
	cd $(IMX_MKIMAGE_DIR) && $(MAKE) SOC=iMX91 flash_singleboot $(LOG_MUTE)
	cp $(IMX91DIR)/flash.bin $(FBOUTDIR)/images/$(MACHINE)-sd-flash.bin
endef
endif

# --- i.MX 93 Family ---
ifdef CONFIG_SOC_IMX93
define build_soc_recipe
	@echo "Building flash.bin for iMX93 $(ATF_OPTINFO)"
	$(call dl_fw_ele)
	$(eval IMX93DIR := $(IMX_MKIMAGE_DIR)/iMX93)
	cp -f $(UBOOT_OUT_DIR)/spl/u-boot-spl.bin $(UBOOT_OUT_DIR)/u-boot.bin $(IMX93DIR)/
	cp -f $(BSPDIR)/atf/build/imx93/release/bl31.bin $(IMX93DIR)/
	cp -f $(BSPDIR)/fw_ele/mx93a*-ahab-container.img $(IMX93DIR)/
	cp -f $(UTILSDIR)/firmware_imx/firmware/ddr/synopsys/*.bin $(IMX93DIR)/
	$(if $(CONFIG_OPTEE),cp -f $(BL32_BIN) $(IMX93DIR)/tee.bin)
	cd $(IMX_MKIMAGE_DIR) && $(MAKE) SOC=iMX93 flash_singleboot $(LOG_MUTE)
	cp $(IMX93DIR)/flash.bin $(FBOUTDIR)/images/$(MACHINE)-sd-flash.bin
endef
endif

# --- i.MX 95 Family ---
ifdef CONFIG_SOC_IMX95
define build_soc_recipe
	@$(call dl_fw_ele)
	$(eval IMX95DIR := $(IMX_MKIMAGE_DIR)/iMX95)
	cp -f $(UTILSDIR)/firmware_imx/firmware/ddr/synopsys/*.bin $(IMX95DIR)/
	cp -f $(BSPDIR)/fw_ele/mx95b0-ahab-container.img $(IMX95DIR)/
	cp -f $(BSPDIR)/atf/build/imx95/release/bl31.bin $(IMX95DIR)/
	cp -f $(BSPDIR)/imx_sm/build/mx95evk/m33_image.bin $(IMX95DIR)/
	cp -f $(UBOOT_OUT_DIR)/spl/u-boot-spl.bin $(UBOOT_OUT_DIR)/u-boot.bin $(IMX95DIR)/
	$(if $(CONFIG_OPTEE),cp -f $(BL32_BIN) $(IMX95DIR)/tee.bin)

	@# 2. Case Specific Files (M7 and OEI)
	$(if $(CONFIG_SOC_IMX95_15X15), \
		cp -f $(BSPDIR)/imx_oei/build/mx95lp4x-15/ddr/oei-m33-ddr.bin $(IMX95DIR)/; \
		cp -f $(UTILSDIR)/mcore_demo/imx95-m7-demo/imx95-15x15-evk_m7_TCM_power_mode_switch.bin $(IMX95DIR)/m7_image.bin; \
		cd $(IMX_MKIMAGE_DIR) && $(MAKE) SOC=iMX95 REV=B0 OEI=YES LPDDR_TYPE=lpddr4x flash_all $(LOG_MUTE); \
	)
	$(if $(CONFIG_SOC_IMX95_19X19), \
		cp -f $(BSPDIR)/imx_oei/build/mx95lp5/ddr/oei-m33-ddr.bin $(IMX95DIR)/; \
		cp -f $(UTILSDIR)/mcore_demo/imx95-m7-demo/imx95-19x19-evk_m7_TCM_power_mode_switch.bin $(IMX95DIR)/m7_image.bin; \
		cd $(IMX_MKIMAGE_DIR) && $(MAKE) SOC=iMX95 REV=B0 OEI=YES flash_all $(LOG_MUTE); \
	)
	cp $(IMX95DIR)/flash.bin $(FBOUTDIR)/images/$(MACHINE)-sd-flash.bin
endef
endif

flash.bin imx_mkimage: uboot atf firmware_imx mcore_demo
	@$(call download_repo,imx_mkimage,bsp)
	$(call patch_apply,imx_mkimage,bsp)
	mkdir -p $(FBOUTDIR)/bsp/imx-mkimage/$(MACHINE)
	cd $(IMX_MKIMAGE_DIR)
	$(MAKE) clean $(LOG_MUTE)
	$(build_soc_recipe)
	$(call fbprint_d,"flash.bin for $(MACHINE) in $(FBOUTDIR)/images/$(MACHINE)-sd-flash.bin")

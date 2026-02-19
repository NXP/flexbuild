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

flash.bin imx_mkimage: uboot atf firmware_imx mcore_demo
#flash.bin imx_mkimage:
	@$(call download_repo,imx_mkimage,bsp)
	$(call patch_apply,imx_mkimage,bsp)
	$(call fbprint_b,"flash.bin for $(MACHINE) $(ATF_OPTINFO)")
	cd $(BSPDIR)/imx_mkimage
	opdir=$(FBOUTDIR)/bsp/u-boot/$(MACHINE)/output/$(uboot_cfg)
	mkdir -p $(FBOUTDIR)/bsp/imx-mkimage/$(MACHINE)
	$(MAKE) clean $(LOG_MUTE)
	bl32=$(PKGDIR)/apps/security/optee_os/out/arm-plat-imx/core/tee_$(MACHINE).bin
	case $(MACHINE) in
		imx8m*)
			IMX8MDIR=$(BSPDIR)/imx_mkimage/iMX8M
			cp -f $$opdir/tools/mkimage $$IMX8MDIR/mkimage_uboot
			cp -f $$opdir/spl/u-boot-spl.bin $$opdir/u-boot-nodtb.bin $$IMX8MDIR/
			if [ "$(CONFIG_OPTEE)" = "y" ]; then
				cp -f $$bl32 $$IMX8MDIR/tee.bin
			fi
			cp -f $(UTILSDIR)/firmware_imx/firmware/hdmi/cadence/signed*_imx8m.bin "$$IMX8MDIR"/
			cp -f $(UTILSDIR)/firmware_imx/firmware/ddr/synopsys/*.bin "$$IMX8MDIR"/
			cd $(BSPDIR)/imx_mkimage
			if [ "$(CONFIG_SOC_IMX8MMEVK)" = "y" ]; then \
				cp -f $$opdir/dts/upstream/src/arm64/freescale/imx8mm-evk.dtb "$$IMX8MDIR"/; \
				cp -f $(BSPDIR)/atf/build/imx8mm/release/bl31.bin "$$IMX8MDIR"/; \
				$(MAKE) SOC=iMX8MM flash_evk $(LOG_MUTE)
			elif [ "$(CONFIG_SOC_IMX8MPEVK)" = "y" ]; then \
				cp -f $$opdir/dts/upstream/src/arm64/freescale/imx8mp-evk.dtb "$$IMX8MDIR"/; \
				cp -f $(BSPDIR)/atf/build/imx8mp/release/bl31.bin "$$IMX8MDIR"/; \
				$(MAKE) SOC=iMX8MP flash_evk $(LOG_MUTE)
			elif [ "$(CONFIG_SOC_IMX8MPFRDM)" = "y" ]; then \
				cp -f $$opdir/arch/arm/dts/imx8mp-frdm.dtb "$$IMX8MDIR"/imx8mp-evk.dtb; \
				cp -f $(BSPDIR)/atf/build/imx8mp/release/bl31.bin "$$IMX8MDIR"/; \
				$(MAKE) SOC=iMX8MP flash_evk $(LOG_MUTE)
			fi
			cp iMX8M/flash.bin $(FBOUTDIR)/images/"$(MACHINE)"-sd-flash.bin
			;;
		imx8qm*)
			SOC_FAMILY=iMX8QM
			$(call dl_imx_scfw)
			$(call dl_imx_seco)
			cp -f $$opdir/u-boot.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY
			cp -f $(BSPDIR)/imx-scfw/mx8qm-mek-scfw-tcm.bin $(BSPDIR)/imx_mkimage/iMX8QM/scfw_tcm.bin
			cp -f $(BSPDIR)/atf/build/imx8qm/release/bl31.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/
			cp -f $(BSPDIR)/imx-seco/firmware/seco/mx8qmb0-ahab-container.img $(BSPDIR)/imx_mkimage/iMX8QM
			cd $(BSPDIR)/imx_mkimage
			if [ "$(CONFIG_OPTEE)" = "y" ]; then
				cp -f $$bl32 $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/tee.bin
				cp -f $$opdir/spl/u-boot-spl.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY
				$(MAKE) SOC=iMX8QM flash_spl $(LOG_MUTE)
			else
				$(MAKE) SOC=iMX8QM flash $(LOG_MUTE)
			fi
			cp iMX8QM/flash.bin $(FBOUTDIR)/images/"$(MACHINE)"-sd-flash.bin
			;;
		imx91*)
			IMX91DIR=$(BSPDIR)/imx_mkimage/iMX91
			$(call dl_fw_ele)
			cp -f $$opdir/spl/u-boot-spl.bin $$opdir/u-boot.bin $$IMX91DIR/
			cp -f $(BSPDIR)/atf/build/imx91/release/bl31.bin $$IMX91DIR/
			cp -f $(BSPDIR)/fw_ele/mx91a*-ahab-container.img $$IMX91DIR/
			if [ "$(CONFIG_OPTEE)" = "y" ]; then
				cp -f $$bl32 $$IMX91DIR/tee.bin
			fi
			cp -f $(UTILSDIR)/firmware_imx/firmware/ddr/synopsys/*.bin $$IMX91DIR/
			cd $(BSPDIR)/imx_mkimage
			$(MAKE) SOC=iMX91 flash_singleboot $(LOG_MUTE)
			cp iMX91/flash.bin $(FBOUTDIR)/images/"$(MACHINE)"-sd-flash.bin
			;;
		imx93*)
			IMX93DIR=$(BSPDIR)/imx_mkimage/iMX93
			$(call dl_fw_ele)
			cp -f $$opdir/spl/u-boot-spl.bin $$opdir/u-boot.bin $$IMX93DIR/
			cp -f $(BSPDIR)/atf/build/imx93/release/bl31.bin $$IMX93DIR/
			cp -f $(BSPDIR)/fw_ele/mx93a*-ahab-container.img $$IMX93DIR/
			if [ "$(CONFIG_OPTEE)" = "y" ]; then
				cp -f $$bl32 $$IMX93DIR/tee.bin
			fi
			cp -f $(UTILSDIR)/firmware_imx/firmware/ddr/synopsys/*.bin $$IMX93DIR/
			cd $(BSPDIR)/imx_mkimage
			$(MAKE) SOC=iMX93 flash_singleboot $(LOG_MUTE)
			cp $$IMX93DIR/flash.bin $(FBOUTDIR)/images/"$(MACHINE)"-sd-flash.bin
			cp iMX93/flash.bin $(FBOUTDIR)/images/"$(MACHINE)"-sd-flash.bin
			;;
		imx95-15x15*)
			SOC_FAMILY=iMX95
			$(call dl_fw_ele)
			cp -f $(UTILSDIR)/firmware_imx/firmware/ddr/synopsys/*.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY
			cp $(BSPDIR)/fw_ele/mx95b0-ahab-container.img $(BSPDIR)/imx_mkimage/iMX95
			cp $(UTILSDIR)/mcore_demo/imx95-m7-demo/imx95-15x15-evk_m7_TCM_power_mode_switch.bin \
				$(BSPDIR)/imx_mkimage/iMX95/m7_image.bin
			cp -f $(BSPDIR)/atf/build/imx95/release/bl31.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/
			cp -f $(BSPDIR)/imx_sm/build/mx95evk/m33_image.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/
			cp -f $(BSPDIR)/imx_oei/build/mx95lp4x-15/ddr/oei-m33-ddr.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/
			cp -f $$opdir/spl/u-boot-spl.bin $$opdir/u-boot.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY
			if [ "$(CONFIG_OPTEE)" = "y" ]; then
				cp -f $$bl32 $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/tee.bin
			fi
			cd $(BSPDIR)/imx_mkimage
			$(MAKE) SOC=iMX95 REV=B0 OEI=YES LPDDR_TYPE=lpddr4x flash_all $(LOG_MUTE)
			cp iMX95/flash.bin $(FBOUTDIR)/images/"$(MACHINE)"-sd-flash.bin
			;;
		imx95-19x19*)
			SOC_FAMILY=iMX95
			$(call dl_fw_ele)
			cp -f $(UTILSDIR)/firmware_imx/firmware/ddr/synopsys/*.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY
			cp $(BSPDIR)/fw_ele/mx95b0-ahab-container.img $(BSPDIR)/imx_mkimage/iMX95
			cp $(UTILSDIR)/mcore_demo/imx95-m7-demo/imx95-19x19-evk_m7_TCM_power_mode_switch.bin \
				$(BSPDIR)/imx_mkimage/iMX95/m7_image.bin
			cp -f $(BSPDIR)/atf/build/imx95/release/bl31.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/
			cp -f $(BSPDIR)/imx_sm/build/mx95evk/m33_image.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/
			cp -f $(BSPDIR)/imx_oei/build/mx95lp5/ddr/oei-m33-ddr.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/
			cp -f $$opdir/spl/u-boot-spl.bin $$opdir/u-boot.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY
			if [ "$(CONFIG_OPTEE)" = "y" ]; then
				cp -f $$bl32 $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/tee.bin
			fi
			cd $(BSPDIR)/imx_mkimage
			$(MAKE) SOC=iMX95 REV=B0 OEI=YES flash_all $(LOG_MUTE)
			cp iMX95/flash.bin $(FBOUTDIR)/images/"$(MACHINE)"-sd-flash.bin
			;;
	esac
	$(call fbprint_d,"flash.bin for $(MACHINE) in $(FBOUTDIR)/images/$(MACHINE)-sd-flash.bin")

# Copyright 2020-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


UTILSDIR = $(PKGDIR)/apps/utils

define dl_imx_seco
	if [ ! -d $(BSPDIR)/imx-seco/firmware/seco ]; then \
		cd $(BSPDIR) && $(call dl_by_wget,seco_bin,imx-seco.bin) && chmod +x $(FBDIR)/dl/imx-seco.bin && \
		$(FBDIR)/dl/imx-seco.bin --auto-accept --force $(LOG_MUTE) && mv `basename -s .bin $(repo_seco_bin_url)` imx-seco; \
	fi
endef

define dl_fw_ele
    if [ ! -d $(BSPDIR)/fw_ele ]; then \
		cd $(BSPDIR) && $(call dl_by_wget,fw_ele_bin,fw_ele.bin) && chmod +x $(FBDIR)/dl/fw_ele.bin && \
		$(FBDIR)/dl/fw_ele.bin --auto-accept --force $(LOG_MUTE) && mv `basename -s .bin $(repo_fw_ele_bin_url)` fw_ele; \
    fi
endef

define dl_fw_upower
    if [ ! -d $(BSPDIR)/fw_upower ]; then \
		cd $(BSPDIR) && $(call dl_by_wget,fw_upower_bin,fw_upower.bin) && chmod +x $(FBDIR)/dl/fw_upower.bin && \
		$(FBDIR)/dl/fw_upower.bin --auto-accept --force $(LOG_MUTE) && mv `basename -s .bin $(repo_fw_upower_bin_url)` fw_upower; \
    fi
endef

define dl_imx_scfw
    if [ ! -d $(BSPDIR)/imx-scfw ]; then \
		cd $(BSPDIR) && $(call dl_by_wget,scfw_bin,imx-scfw.bin) && chmod +x $(FBDIR)/dl/imx-scfw.bin && \
		$(FBDIR)/dl/imx-scfw.bin --auto-accept --force $(LOG_MUTE) && mv `basename -s .bin $(repo_scfw_bin_url)` imx-scfw; \
    fi
endef

define imx_mkimage_target
	$(call download_repo,imx_mkimage,bsp) && \
	$(call patch_apply,imx_mkimage,bsp) && \
    \
	bld firmware_imx -m $(MACHINE); \
	\
    cd $(BSPDIR)/imx_mkimage && \
    mkdir -p $(FBOUTDIR)/bsp/imx-mkimage/$(MACHINE) && \
	$(MAKE) clean $(LOG_MUTE) && \
    \
    bl32=$(PKGDIR)/apps/security/optee_os/out/arm-plat-imx/core/tee_$(MACHINE).bin && \
    \
	case $(MACHINE) in \
		imx8mpfrdm) \
			SOC_FAMILY=iMX8M; \
			cp -f $(UTILSDIR)/firmware_imx/firmware/ddr/synopsys/*.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY; \
			cp -f $$opdir/arch/arm/dts/imx8mp-frdm.dtb $(BSPDIR)/imx_mkimage/$$SOC_FAMILY; \
			cp -f $$opdir/tools/mkimage $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/mkimage_uboot; \
			cp -f $(BSPDIR)/atf/build/imx8mp/release/bl31.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/; \
			cp -t $(BSPDIR)/imx_mkimage/$$SOC_FAMILY \
				$(UTILSDIR)/firmware_imx/firmware/hdmi/cadence/signed*_imx8m.bin \
				$$opdir/spl/u-boot-spl.bin $$opdir/u-boot.bin \
				$$opdir/u-boot-nodtb.bin; \
			cp -f $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/imx8mp-frdm.dtb $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/imx8mp-evk.dtb; \
			if [ "$(CONFIG_OPTEE)" = "y" ]; then \
				if [ ! -f "$$bl32" ]; then \
					echo "$$bl32 does not exist, OPTEE was disabled automatically."; \
				else \
					cp -f $$bl32 $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/tee.bin; \
				fi; \
			fi;  \
			cd $(BSPDIR)/imx_mkimage; \
			$(MAKE) SOC=iMX8MP flash_evk $(LOG_MUTE); \
			;; \
		imx8mp*) \
			SOC_FAMILY=iMX8M; \
			cp -f $(UTILSDIR)/firmware_imx/firmware/ddr/synopsys/*.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY; \
			cp -f $$opdir/dts/upstream/src/arm64/freescale/imx8mp-evk.dtb $(BSPDIR)/imx_mkimage/$$SOC_FAMILY; \
			cp -f $$opdir/tools/mkimage $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/mkimage_uboot; \
			cp -f $(BSPDIR)/atf/build/imx8mp/release/bl31.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/; \
			cp -t $(BSPDIR)/imx_mkimage/$$SOC_FAMILY \
				$(UTILSDIR)/firmware_imx/firmware/hdmi/cadence/signed*_imx8m.bin \
				$$opdir/spl/u-boot-spl.bin $$opdir/u-boot.bin \
				$$opdir/u-boot-nodtb.bin; \
			if [ "$(CONFIG_OPTEE)" = "y" ]; then \
				if [ ! -f "$$bl32" ]; then \
					echo "$$bl32 does not exist, OPTEE was disabled automatically."; \
				else \
					cp -f $$bl32 $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/tee.bin; \
				fi; \
			fi;  \
			cd $(BSPDIR)/imx_mkimage; \
			$(MAKE) SOC=iMX8MP flash_evk $(LOG_MUTE); \
			;; \
		imx8mm*) \
			SOC_FAMILY=iMX8M; \
			cp -f $(UTILSDIR)/firmware_imx/firmware/ddr/synopsys/*.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY; \
			cp -f $$opdir/dts/upstream/src/arm64/freescale/imx8mm-evk.dtb $(BSPDIR)/imx_mkimage/$$SOC_FAMILY; \
			cp -f $$opdir/tools/mkimage $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/mkimage_uboot; \
			cp -f $(BSPDIR)/atf/build/imx8mm/release/bl31.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/; \
			cp -t $(BSPDIR)/imx_mkimage/$$SOC_FAMILY \
				$(UTILSDIR)/firmware_imx/firmware/hdmi/cadence/signed*_imx8m.bin \
				$$opdir/spl/u-boot-spl.bin $$opdir/u-boot.bin \
				$$opdir/u-boot-nodtb.bin; \
			if [ "$(CONFIG_OPTEE)" = "y" ]; then \
				if [ ! -f "$$bl32" ]; then \
					echo "$$bl32 does not exist, OPTEE was disabled automatically."; \
				else \
					cp -f $$bl32 $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/tee.bin; \
				fi; \
			fi;  \
			cd $(BSPDIR)/imx_mkimage; \
			$(MAKE) SOC=iMX8MM flash_evk $(LOG_MUTE); \
			;; \
		imx8mn*) \
			SOC_FAMILY=iMX8M; \
			cp -f $(UTILSDIR)/firmware_imx/firmware/ddr/synopsys/*.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY; \
			cp -f $$opdir/dts/upstream/src/arm64/freescale/imx8mn-evk.dtb $(BSPDIR)/imx_mkimage/$$SOC_FAMILY; \
			cp -f $$opdir/tools/mkimage $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/mkimage_uboot; \
			cp -f $(BSPDIR)/atf/build/imx8mn/release/bl31.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/; \
			cp -t $(BSPDIR)/imx_mkimage/$$SOC_FAMILY \
				$(UTILSDIR)/firmware_imx/firmware/hdmi/cadence/signed*_imx8m.bin \
				$$opdir/spl/u-boot-spl.bin $$opdir/u-boot.bin \
				$$opdir/u-boot-nodtb.bin; \
			if [ "$(CONFIG_OPTEE)" = "y" ]; then \
				if [ ! -f "$$bl32" ]; then \
					echo "$$bl32 does not exist, OPTEE was disabled automatically."; \
				else \
					cp -f $$bl32 $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/tee.bin; \
				fi; \
			fi;  \
			cd $(BSPDIR)/imx_mkimage; \
			$(MAKE) SOC=iMX8MN flash_evk $(LOG_MUTE); \
			;; \
		imx8mq*) \
			SOC_FAMILY=iMX8M; \
			cp -f $(UTILSDIR)/firmware_imx/firmware/ddr/synopsys/*.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY; \
			cp -f $$opdir/dts/upstream/src/arm64/freescale/imx8mq-evk.dtb $(BSPDIR)/imx_mkimage/$$SOC_FAMILY; \
			cp -f $$opdir/tools/mkimage $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/mkimage_uboot; \
			cp -f $(BSPDIR)/atf/build/imx8mq/release/bl31.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/; \
			cp -t $(BSPDIR)/imx_mkimage/$$SOC_FAMILY \
				$(UTILSDIR)/firmware_imx/firmware/hdmi/cadence/signed*_imx8m.bin \
				$$opdir/spl/u-boot-spl.bin $$opdir/u-boot.bin \
				$$opdir/u-boot-nodtb.bin; \
			if [ "$(CONFIG_OPTEE)" = "y" ]; then \
				if [ ! -f "$$bl32" ]; then \
					echo "$$bl32 does not exist, OPTEE was disabled automatically."; \
				else \
					cp -f $$bl32 $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/tee.bin; \
				fi; \
			fi;  \
			cd $(BSPDIR)/imx_mkimage; \
			$(MAKE) SOC=iMX8M flash_evk $(LOG_MUTE); \
			;; \
        imx8qm*) \
			SOC_FAMILY=iMX8QM; \
			$(call dl_imx_scfw); \
			$(call dl_imx_seco); \
			cp -f $(UTILSDIR)/firmware_imx/firmware/ddr/synopsys/*.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY; \
			cp -f $$opdir/arch/arm/dts/fsl-imx8qm-mek.dtb $(BSPDIR)/imx_mkimage/$$SOC_FAMILY; \
            cp -f $(BSPDIR)/imx-scfw/mx8qm-mek-scfw-tcm.bin $(BSPDIR)/imx_mkimage/iMX8QM/scfw_tcm.bin; \
            cp -f $(BSPDIR)/imx-seco/firmware/seco/mx8qmb0-ahab-container.img $(BSPDIR)/imx_mkimage/iMX8QM; \
			cp -f $$opdir/tools/mkimage $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/mkimage_uboot; \
			cp -f $(BSPDIR)/atf/build/imx8qm/release/bl31.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/; \
			cp -t $(BSPDIR)/imx_mkimage/$$SOC_FAMILY \
				$(UTILSDIR)/firmware_imx/firmware/hdmi/cadence/signed*_imx8m.bin \
				$$opdir/spl/u-boot-spl.bin $$opdir/u-boot.bin \
				$$opdir/u-boot-nodtb.bin; \
			if [ "$(CONFIG_OPTEE)" = "y" ]; then \
				if [ ! -f "$$bl32" ]; then \
					echo "$$bl32 does not exist, OPTEE was disabled automatically."; \
				else \
					cp -f $$bl32 $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/tee.bin; \
				fi; \
			fi;  \
			cd $(BSPDIR)/imx_mkimage; \
			$(MAKE) SOC=iMX8QM flash $(LOG_MUTE); \
            ;; \
        imx8qx*) \
			SOC_FAMILY=iMX8QX; \
			$(call dl_imx_scfw); \
			$(call dl_imx_seco); \
			cp -f $(UTILSDIR)/firmware_imx/firmware/ddr/synopsys/*.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY; \
			cp -f $$opdir/arch/arm/dts/fsl-imx8dx-mek.dtb $(BSPDIR)/imx_mkimage/$$SOC_FAMILY; \
            cp -f $(BSPDIR)/imx-scfw/mx8qx-mek-scfw-tcm.bin $(BSPDIR)/imx_mkimage/iMX8QX/scfw_tcm.bin; \
            cp -f $(BSPDIR)/imx-seco/firmware/seco/mx8qx*-ahab-container.img $(BSPDIR)/imx_mkimage/iMX8QX; \
			cp -f $$opdir/tools/mkimage $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/mkimage_uboot; \
			cp -f $(BSPDIR)/atf/build/imx8qx/release/bl31.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/; \
			cp -t $(BSPDIR)/imx_mkimage/$$SOC_FAMILY \
				$(UTILSDIR)/firmware_imx/firmware/hdmi/cadence/signed*_imx8m.bin \
				$$opdir/spl/u-boot-spl.bin $$opdir/u-boot.bin \
				$$opdir/u-boot-nodtb.bin; \
			if [ "$(CONFIG_OPTEE)" = "y" ]; then \
				if [ ! -f "$$bl32" ]; then \
					echo "$$bl32 does not exist, OPTEE was disabled automatically."; \
				else \
					cp -f $$bl32 $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/tee.bin; \
				fi; \
			fi;  \
			cd $(BSPDIR)/imx_mkimage; \
            $(MAKE) SOC=iMX8QX flash $(LOG_MUTE); \
            ;; \
		imx8ulp*) \
			SOC_FAMILY=iMX8ULP; \
			$(call dl_fw_ele); \
			$(call dl_fw_upower); \
			bld mcore_demo -m $(MACHINE); \
			cp -f $(UTILSDIR)/firmware_imx/firmware/ddr/synopsys/*.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY; \
			cp -f $$opdir/arch/arm/dts/imx8ulp-evk.dtb $(BSPDIR)/imx_mkimage/$$SOC_FAMILY; \
            cp $(BSPDIR)/fw_ele/mx8ulpa2-ahab-container.img $(BSPDIR)/imx_mkimage/iMX8ULP; \
            cp $(BSPDIR)/fw_upower/upower_a1.bin $(BSPDIR)/imx_mkimage/iMX8ULP/upower.bin; \
            cp $(UTILSDIR)/mcore_demo/imx8ulp-m33-demo/imx8ulp_m33_TCM_rpmsg_lite_str_echo_rtos.bin \
               $(BSPDIR)/imx_mkimage/iMX8ULP/m33_image.bin; \
			cp -f $$opdir/tools/mkimage $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/mkimage_uboot; \
			cp -f $(BSPDIR)/atf/build/imx8ulp/release/bl31.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/; \
			cp -t $(BSPDIR)/imx_mkimage/$$SOC_FAMILY \
				$(UTILSDIR)/firmware_imx/firmware/hdmi/cadence/signed*_imx8m.bin \
				$$opdir/spl/u-boot-spl.bin $$opdir/u-boot.bin \
				$$opdir/u-boot-nodtb.bin; \
			if [ "$(CONFIG_OPTEE)" = "y" ]; then \
				if [ ! -f "$$bl32" ]; then \
					echo "$$bl32 does not exist, OPTEE was disabled automatically."; \
				else \
					cp -f $$bl32 $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/tee.bin; \
				fi; \
			fi;  \
			cd $(BSPDIR)/imx_mkimage; \
			$(MAKE) SOC=iMX8ULP flash_singleboot_m33 $(LOG_MUTE); \
			;; \
        imx91s*) \
			SOC_FAMILY=iMX91; \
			$(call dl_fw_ele); \
			$(call dl_fw_upower); \
			cp -f $(UTILSDIR)/firmware_imx/firmware/ddr/synopsys/*.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY; \
			cp -f $$opdir/arch/arm/dts/imx91-11x11-frdm.dtb $(BSPDIR)/imx_mkimage/$$SOC_FAMILY; \
            cp $(BSPDIR)/fw_ele/mx91a*-ahab-container.img $(BSPDIR)/imx_mkimage/iMX91; \
            cp $(BSPDIR)/fw_upower/upower_a*.bin $(BSPDIR)/imx_mkimage/iMX91/; \
			cp -f $$opdir/tools/mkimage $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/mkimage_uboot; \
			cp -f $(BSPDIR)/atf/build/imx91/release/bl31.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/; \
			cp -t $(BSPDIR)/imx_mkimage/$$SOC_FAMILY \
				$(UTILSDIR)/firmware_imx/firmware/hdmi/cadence/signed*_imx8m.bin \
				$$opdir/spl/u-boot-spl.bin $$opdir/u-boot.bin \
				$$opdir/u-boot-nodtb.bin; \
			if [ "$(CONFIG_OPTEE)" = "y" ]; then \
				if [ ! -f "$$bl32" ]; then \
					echo "$$bl32 does not exist, OPTEE was disabled automatically."; \
				else \
					cp -f $$bl32 $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/tee.bin; \
				fi; \
			fi;  \
			cd $(BSPDIR)/imx_mkimage; \
            $(MAKE) SOC=iMX91 flash_singleboot $(LOG_MUTE) ; \
            ;; \
        imx91frdm) \
			SOC_FAMILY=iMX91; \
			$(call dl_fw_ele); \
			$(call dl_fw_upower); \
			cp -f $(UTILSDIR)/firmware_imx/firmware/ddr/synopsys/*.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY; \
			cp -f $$opdir/arch/arm/dts/imx91-11x11-frdm.dtb $(BSPDIR)/imx_mkimage/$$SOC_FAMILY; \
            cp $(BSPDIR)/fw_ele/mx91a*-ahab-container.img $(BSPDIR)/imx_mkimage/iMX91; \
            cp $(BSPDIR)/fw_upower/upower_a*.bin $(BSPDIR)/imx_mkimage/iMX91/; \
			cp -f $$opdir/tools/mkimage $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/mkimage_uboot; \
			cp -f $(BSPDIR)/atf/build/imx91/release/bl31.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/; \
			cp -t $(BSPDIR)/imx_mkimage/$$SOC_FAMILY \
				$(UTILSDIR)/firmware_imx/firmware/hdmi/cadence/signed*_imx8m.bin \
				$$opdir/spl/u-boot-spl.bin $$opdir/u-boot.bin \
				$$opdir/u-boot-nodtb.bin; \
			if [ "$(CONFIG_OPTEE)" = "y" ]; then \
				if [ ! -f "$$bl32" ]; then \
					echo "$$bl32 does not exist, OPTEE was disabled automatically."; \
				else \
					cp -f $$bl32 $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/tee.bin; \
				fi; \
			fi;  \
			cd $(BSPDIR)/imx_mkimage; \
            $(MAKE) SOC=iMX91 flash_singleboot $(LOG_MUTE) ; \
            ;; \
        imx91evk) \
			SOC_FAMILY=iMX91; \
			$(call dl_fw_ele); \
			$(call dl_fw_upower); \
			cp -f $(UTILSDIR)/firmware_imx/firmware/ddr/synopsys/*.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY; \
			cp -f $$opdir/dts/upstream/src/arm64/freescale/imx91-11x11-evk.dtb $(BSPDIR)/imx_mkimage/$$SOC_FAMILY; \
            cp $(BSPDIR)/fw_ele/mx91a*-ahab-container.img $(BSPDIR)/imx_mkimage/iMX91; \
            cp $(BSPDIR)/fw_upower/upower_a*.bin $(BSPDIR)/imx_mkimage/iMX91/; \
			cp -f $$opdir/tools/mkimage $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/mkimage_uboot; \
			cp -f $(BSPDIR)/atf/build/imx91/release/bl31.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/; \
			cp -t $(BSPDIR)/imx_mkimage/$$SOC_FAMILY \
				$(UTILSDIR)/firmware_imx/firmware/hdmi/cadence/signed*_imx8m.bin \
				$$opdir/spl/u-boot-spl.bin $$opdir/u-boot.bin \
				$$opdir/u-boot-nodtb.bin; \
			if [ "$(CONFIG_OPTEE)" = "y" ]; then \
				if [ ! -f "$$bl32" ]; then \
					echo "$$bl32 does not exist, OPTEE was disabled automatically."; \
				else \
					cp -f $$bl32 $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/tee.bin; \
				fi; \
			fi;  \
			cd $(BSPDIR)/imx_mkimage; \
            $(MAKE) SOC=iMX91 flash_singleboot $(LOG_MUTE) ; \
            ;; \
        imx93frdm) \
			SOC_FAMILY=iMX93; \
			$(call dl_fw_ele); \
			$(call dl_fw_upower); \
			bld mcore_demo -m $(MACHINE); \
			cp -f $(UTILSDIR)/firmware_imx/firmware/ddr/synopsys/*.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY; \
			cp -f $$opdir/arch/arm/dts/imx93-11x11-frdm.dtb $(BSPDIR)/imx_mkimage/$$SOC_FAMILY; \
            cp $(BSPDIR)/fw_ele/mx93a*-ahab-container.img $(BSPDIR)/imx_mkimage/iMX93; \
            cp $(BSPDIR)/fw_upower/upower_a*.bin $(BSPDIR)/imx_mkimage/iMX93/; \
            cp $(UTILSDIR)/mcore_demo/imx93-m33-demo/imx93-11x11-evk_m33_TCM_rpmsg_lite_str_echo_rtos.bin \
               $(BSPDIR)/imx_mkimage/iMX93/m33_image.bin; \
			cp -f $$opdir/tools/mkimage $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/mkimage_uboot; \
			cp -f $(BSPDIR)/atf/build/imx93/release/bl31.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/; \
			cp -t $(BSPDIR)/imx_mkimage/$$SOC_FAMILY \
				$(UTILSDIR)/firmware_imx/firmware/hdmi/cadence/signed*_imx8m.bin \
				$$opdir/spl/u-boot-spl.bin $$opdir/u-boot.bin \
				$$opdir/u-boot-nodtb.bin; \
			if [ "$(CONFIG_OPTEE)" = "y" ]; then \
				if [ ! -f "$$bl32" ]; then \
					echo "$$bl32 does not exist, OPTEE was disabled automatically."; \
				else \
					cp -f $$bl32 $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/tee.bin; \
				fi; \
			fi;  \
			cd $(BSPDIR)/imx_mkimage; \
            $(MAKE) SOC=iMX93 flash_singleboot $(LOG_MUTE) ; \
            ;; \
        imx93evk) \
			SOC_FAMILY=iMX93; \
			$(call dl_fw_ele); \
			$(call dl_fw_upower); \
			bld mcore_demo -m $(MACHINE); \
			cp -f $(UTILSDIR)/firmware_imx/firmware/ddr/synopsys/*.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY; \
			cp -f $$opdir/dts/upstream/src/arm64/freescale/imx93-11x11-evk.dtb $(BSPDIR)/imx_mkimage/$$SOC_FAMILY; \
            cp $(BSPDIR)/fw_ele/mx93a*-ahab-container.img $(BSPDIR)/imx_mkimage/iMX93; \
            cp $(BSPDIR)/fw_upower/upower_a*.bin $(BSPDIR)/imx_mkimage/iMX93/; \
            cp $(UTILSDIR)/mcore_demo/imx93-m33-demo/imx93-11x11-evk_m33_TCM_rpmsg_lite_str_echo_rtos.bin \
               $(BSPDIR)/imx_mkimage/iMX93/m33_image.bin; \
			cp -f $$opdir/tools/mkimage $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/mkimage_uboot; \
			cp -f $(BSPDIR)/atf/build/imx93/release/bl31.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/; \
			cp -t $(BSPDIR)/imx_mkimage/$$SOC_FAMILY \
				$(UTILSDIR)/firmware_imx/firmware/hdmi/cadence/signed*_imx8m.bin \
				$$opdir/spl/u-boot-spl.bin $$opdir/u-boot.bin \
				$$opdir/u-boot-nodtb.bin; \
			if [ "$(CONFIG_OPTEE)" = "y" ]; then \
				if [ ! -f "$$bl32" ]; then \
					echo "$$bl32 does not exist, OPTEE was disabled automatically."; \
				else \
					cp -f $$bl32 $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/tee.bin; \
				fi; \
			fi;  \
			cd $(BSPDIR)/imx_mkimage; \
            $(MAKE) SOC=iMX93 flash_singleboot $(LOG_MUTE) ; \
            ;; \
        imx95evk) \
			SOC_FAMILY=iMX95; \
			$(call dl_fw_ele); \
			bld mcore_demo -m $(MACHINE); \
			cp -f $(UTILSDIR)/firmware_imx/firmware/ddr/synopsys/*.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY; \
			cp -f $$opdir/arch/arm/dts/imx95-15x15-evk.dtb $(BSPDIR)/imx_mkimage/$$SOC_FAMILY; \
			cp $(BSPDIR)/fw_ele/mx95b0-ahab-container.img $(BSPDIR)/imx_mkimage/iMX95; \
			cp $(UTILSDIR)/mcore_demo/imx95-m7-demo/imx95-15x15-evk_m7_TCM_power_mode_switch.bin \
				$(BSPDIR)/imx_mkimage/iMX95/m7_image.bin; \
			cp -f $(BSPDIR)/atf/build/imx95/release/bl31.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/; \
			cp -f $(BSPDIR)/imx_sm/build/mx95evk/m33_image.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/; \
			cp -f $(BSPDIR)/imx_oei/build/mx95lp4x-15/ddr/oei-m33-ddr.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/; \
			cp -t $(BSPDIR)/imx_mkimage/$$SOC_FAMILY \
				$(UTILSDIR)/firmware_imx/firmware/hdmi/cadence/signed*_imx8m.bin \
				$$opdir/spl/u-boot-spl.bin $$opdir/u-boot.bin \
				$$opdir/u-boot-nodtb.bin; \
			if [ "$(CONFIG_OPTEE)" = "y" ]; then \
				if [ ! -f "$$bl32" ]; then \
					echo "$$bl32 does not exist, OPTEE was disabled automatically."; \
				else \
					cp -f $$bl32 $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/tee.bin; \
				fi; \
			fi;  \
			cd $(BSPDIR)/imx_mkimage; \
			$(MAKE) SOC=iMX95 REV=B0 OEI=YES LPDDR_TYPE=lpddr4x flash_all $(LOG_MUTE); \
            ;; \
        imx95frdm) \
			SOC_FAMILY=iMX95; \
			$(call dl_fw_ele); \
			bld mcore_demo -m $(MACHINE); \
			cp -f $(UTILSDIR)/firmware_imx/firmware/ddr/synopsys/*.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY; \
			cp -f $$opdir/arch/arm/dts/imx95-15x15-frdm.dtb $(BSPDIR)/imx_mkimage/$$SOC_FAMILY; \
			cp $(BSPDIR)/fw_ele/mx95b0-ahab-container.img $(BSPDIR)/imx_mkimage/iMX95; \
			cp $(UTILSDIR)/mcore_demo/imx95-m7-demo/imx95-15x15-evk_m7_TCM_power_mode_switch.bin \
				$(BSPDIR)/imx_mkimage/iMX95/m7_image.bin; \
			cp -f $(BSPDIR)/atf/build/imx95/release/bl31.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/; \
			cp -f $(BSPDIR)/imx_sm/build/mx95evk/m33_image.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/; \
			cp -f $(BSPDIR)/imx_oei/build/mx95lp4x-15/ddr/oei-m33-ddr.bin $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/; \
			cp -t $(BSPDIR)/imx_mkimage/$$SOC_FAMILY \
				$(UTILSDIR)/firmware_imx/firmware/hdmi/cadence/signed*_imx8m.bin \
				$$opdir/spl/u-boot-spl.bin $$opdir/u-boot.bin \
				$$opdir/u-boot-nodtb.bin; \
			if [ "$(CONFIG_OPTEE)" = "y" ]; then \
				if [ ! -f "$$bl32" ]; then \
					echo "$$bl32 does not exist, OPTEE was disabled automatically."; \
				else \
					cp -f $$bl32 $(BSPDIR)/imx_mkimage/$$SOC_FAMILY/tee.bin; \
				fi; \
			fi;  \
			cd $(BSPDIR)/imx_mkimage; \
			$(MAKE) SOC=iMX95 REV=B0 OEI=YES LPDDR_TYPE=lpddr4x flash_all $(LOG_MUTE); \
            ;; \
    esac && \
    cp $$SOC_FAMILY/flash.bin $(FBOUTDIR)/bsp/imx-mkimage/$(MACHINE)/flash.bin;
endef

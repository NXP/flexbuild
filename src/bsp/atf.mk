#
# Copyright 2018-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#

# build ATF image for Layerscape and i.MX platforms

bldstr = "BUILD_STRING=$(DEFAULT_REPO_TAG)"

define atf_imx
	if [ "$(CONFIG_OPTEE)" = y ]; then \
		bl32=$(PKGDIR)/apps/security/optee_os/out/arm-plat-imx/core/tee_$(MACHINE).bin; \
		bl32opt="BL32=$$bl32" && spdopt="SPD=opteed"; \
		[ ! -f $$bl32 ] && CONFIG_OPTEE=y bld optee_os -m $(MACHINE); \
    fi; \
	[ $${MACHINE:0:7} = imx8ulp ] && plat=$${MACHINE:0:7} || plat=$${MACHINE:0:6} && \
	[ $${MACHINE:0:4} = imx9 ] && plat=$${MACHINE:0:5} || true && \
	$(MAKE) -j$(JOBS) PLAT=$$plat $(bldstr) bl31 $$bl32opt $$spdopt $(LOG_MUTE) && \
	mkdir -p $(FBOUTDIR)/bsp/atf/$(MACHINE) && \
	cp -f build/$$plat/release/bl31.bin $(FBOUTDIR)/bsp/atf/$(MACHINE)/
endef

define atf_ls
	[ $${MACHINE:0:6} = ls1012 -o $${MACHINE:0:5} = ls104 ] && \
        chassistype=ls104x_1012 || chassistype=ls2088_1088; \
    if [ "$(SECURE)" = y ]; then \
        if [ $$chassistype = ls104x_1012 ]; then \
            rcwbin=`grep ^rcw_$(BOOTTYPE)_sec= $(FBDIR)/configs/board/$(MACHINE).conf | cut -d'"' -f2`; \
        else \
            rcwbin=`grep ^rcw_$(BOOTTYPE)= $(FBDIR)/configs/board/$(MACHINE).conf | cut -d'"' -f2`; \
        fi; \
        if [ $${MACHINE:0:5} = lx216 ] && [ ! -f $(PKGDIR)/bsp/atf/ddr4_pmu_train_dmem.bin ]; then \
            bld ddr_phy_bin -m $(MACHINE); \
        fi && \
        if [ ! -d $(PKGDIR)/apps/security/mbedtls ]; then \
            bld mbedtls -m $(MACHINE); \
        fi && \
        if [ "$(COT)" = arm-cot -o "$(COT)" = arm-cot-with-verified-boot ]; then \
            secureopt="TRUSTED_BOARD_BOOT=1 CST_DIR=$(PKGDIR)/apps/security/cst GENERATE_COT=1 MBEDTLS_DIR=$(PKGDIR)/apps/security/mbedtls"; \
            outputdir="arm-cot"; \
            mkdir -p $$outputdir build/$(MACHINE)/release; \
            [ -f $$outputdir/rot_key.pem ] && cp -f $$outputdir/*.pem build/$(MACHINE)/release/; \
			bl33=$(FBOUTDIR)/bsp/u-boot/$(MACHINE)/uboot_$(MACHINE)_tfa_SECURE_BOOT.bin; \
			secext=_sec; \
        else \
            secureopt="TRUSTED_BOARD_BOOT=1 CST_DIR=$(PKGDIR)/apps/security/cst"; \
            outputdir="nxp-cot" && mkdir -p $$outputdir; \
            bl33=$(FBOUTDIR)/bsp/u-boot/$(MACHINE)/uboot_$(MACHINE)_tfa_SECURE_BOOT.bin; \
            secext=_sec; \
        fi; \
        [ ! -f $(PKGDIR)/apps/security/cst/srk.pub ] && bld cst -m $(MACHINE); \
        cp -f $(PKGDIR)/apps/security/cst/srk.* $(PKGDIR)/bsp/atf; \
    else \
        bl33=$(FBOUTDIR)/bsp/u-boot/$(MACHINE)/uboot_$(MACHINE)_tfa.bin; \
        rcwbin=`grep ^rcw_$(BOOTTYPE)= $(FBDIR)/configs/board/$(MACHINE).conf | cut -d'"' -f2`; \
    fi && \
    if [ -z "$$rcwbin" ]; then \
        echo $(MACHINE) $(BOOTTYPE)boot$$secext is not supported && exit 0; \
    fi && \
    rcwbin=$(FBOUTDIR)/$$rcwbin && \
	if [ ! -f $$rcwbin ]; then \
		bld rcw -m $(MACHINE); \
		test -f $$rcwbin || { $(call fbprint_e,"$$rcwbin not exist"); exit;} \
	fi; \
    if [ "$(CONFIG_FUSE_PROVISIONING)" = y ]; then \
        fusefile=$(PKGDIR)/apps/security/cst/fuse_scr.bin && \
        fuseopt="fip_fuse FUSE_PROG=1 FUSE_PROV_FILE=$$fusefile" && \
        if [ ! -d $(PKGDIR)/apps/security/cst ]; then bld cst -m $(MACHINE); fi && \
        $(call fbprint_b,"dependent fuse_scr.bin") && \
        cd $(PKGDIR)/apps/security/cst && \
        ./gen_fusescr input_files/gen_fusescr/$$chassistype/input_fuse_file && \
        cd -; \
    fi; \
    if [ "$(CONFIG_OPTEE)" = y ]; then \
            bl32=$(PKGDIR)/apps/security/optee_os/out/arm-plat-ls/core/tee_$(MACHINE).bin; \
            bl32opt="BL32=$$bl32" && spdopt="SPD=opteed"; \
            [ ! -f $$bl32 ] && CONFIG_OPTEE=y bld optee_os -m $(MACHINE); \
    fi; \
	if [ ! -f $$bl33 ]; then \
		echo building dependent $$bl33 $(LOG_MUTE); \
		bld uboot -m $(MACHINE) -b tfa; \
	fi; \
    if [ $(BOOTTYPE) = xspi ]; then \
        bootmode=flexspi_nor; \
    else \
        bootmode=$(BOOTTYPE); \
    fi && \
	\
	echo $(MAKE) -j$(JOBS) fip pbl PLAT=$(MACHINE) BOOT_MODE=$$bootmode RCW=$$rcwbin BL33=$$bl33 $$bl32opt $$spdopt $$secureopt $$fuseopt ${LOG_MUTE} && \
	$(MAKE) -j$(JOBS) fip pbl PLAT=$(MACHINE) BOOT_MODE=$$bootmode RCW=$$rcwbin BL33=$$bl33 $$bl32opt $$spdopt $$secureopt $$fuseopt $(bldstr) $(LOG_MUTE) && \
	if [ $${MACHINE:0:5} = lx216 -a "$(SECURE)" = y ] && [ ! -f $$outputdir/ddr_fip_sec.bin ]; then \
		$(MAKE) -j$(JOBS) fip_ddr PLAT=$(MACHINE) BOOT_MODE=$$bootmode $$secureopt $(bldstr) $$fuseopt DDR_PHY_BIN_PATH=$(PKGDIR)/bsp/ddr_phy_bin/lx2160a $(LOG_MUTE); \
		[ "$(COT)" = arm-cot -o "$(COT)" = arm-cot-with-verified-boot ] && cp -f build/$(MACHINE)/release/*.pem $$outputdir/; \
		cp -f build/$(MACHINE)/release/ddr_fip_sec.bin $$outputdir/; \
	fi && \
	[ $${MACHINE:0:5} = lx216 -a "$(SECURE)" = y -a -f $$outputdir/ddr_fip_sec.bin ] && \
		cp -f $$outputdir/ddr_fip_sec.bin $(FBOUTDIR)/bsp/atf/$(MACHINE)/fip_ddr_sec.bin; \
	cp -f build/$(MACHINE)/release/bl2_$$bootmode*.pbl $(FBOUTDIR)/bsp/atf/$(MACHINE)/ && \
	cp -f build/$(MACHINE)/release/fip.bin $(FBOUTDIR)/bsp/atf/$(MACHINE)/fip_uboot$$secext.bin && \
	if [ "$(CONFIG_FUSE_PROVISIONING)" = "y" ]; then \
		cp -f build/$(MACHINE)/release/fuse_fip.bin $(FBOUTDIR)/bsp/atf/$(MACHINE)/fuse_fip$$secext.bin; \
	fi
endef

atf:
	@$(call download_repo,atf,bsp) && \
    if [ "$(MACHINE)" = all ]; then \
        $(call fbprint_w,"Please specify '-m <machine>'") && exit 0; \
    fi && \
    if [ -z "$(BOOTTYPE)" ]; then \
        $(call fbprint_w,"Please specify '-b <boottype>'") && exit 0; \
    fi && \
	if [ "$(SECURE)" = y ]; then \
		sboot_info="[secure mode]"; \
	else \
		sboot_info=""; \
	fi && \
	if [ "$(CONFIG_OPTEE)" = y ]; then \
		optee_info="[OPTEE enabled]"; \
	else \
		optee_info=""; \
	fi && \
	$(call fbprint_b,"ATF for $(MACHINE) $(BOOTTYPE) boot $${sboot_info} $${optee_info}"); \
    cd $(BSPDIR)/atf && \
    $(MAKE) realclean $(LOG_MUTE) && \
    mkdir -p $(FBOUTDIR)/bsp/atf/$(MACHINE) && \
	if [ "$(SOCFAMILY)" = "IMX" ]; then \
		$(call atf_imx); \
	else \
		$(call atf_ls); \
	fi && \
    ls -l $(FBOUTDIR)/bsp/atf/$(MACHINE)/* ${LOG_MUTE} && \
    $(call fbprint_d,"ATF for $(MACHINE) $${bootmode} boot $${sboot_info} $${optee_info}")

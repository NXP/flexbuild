#
# Copyright 2018-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#

# build ATF image for Layerscape and i.MX platforms

.PHONY: atf
bldstr := "BUILD_STRING=$(DEFAULT_REPO_TAG)"

ATF_DEPS =
ifdef CONFIG_OPTEE
	ATF_DEPS += optee_os
	ATF_OPTINFO := [OPTEE enabled]
endif

ATF_DEPS += $(if $(CONFIG_SOC_IMX95),imx_sm imx_oei)

ifdef CONFIG_PLATFORM_LS
	ATF_DEPS += rcw uboot

	CHASSIS_TYPE := $(if $(filter y,$(CONFIG_SOC_LS104)),ls104x_1012,ls2088_1088)

	ifeq ($(CONFIG_SECURE_BOOT),y)
		SECExt         := _sec
		SECOpt         := TRUSTED_BOARD_BOOT=1 CST_DIR=$(PKGDIR)/apps/security/cst
		ifdef CONFIG_SOC_LX2160ARDB
			ATF_DEPS += ddr_phy_bin
		endif
		ATF_SECINFO := [secure boot]
		ifeq ($(CHASSIS_TYPE),ls104x_1012)
			RCWExt := _sec
		endif
		ATF_DEPS += cst
	endif
	ifeq ($(CONFIG_FUSE_PROVISIONING),y)
		ATF_DEPS += cst
		ATF_FUSEINFO := [FUSE enabled]
	endif
    $(foreach var,$(filter rcw_%,$(.VARIABLES)),$(eval export $(var) := $($(var))))
endif

define atf_imx
	if [ "$(CONFIG_OPTEE)" = y ]; then
		bl32opt="BL32=$(PKGDIR)/apps/security/optee_os/out/arm-plat-imx/core/tee_$(MACHINE).bin SPD=opteed"
	fi
	$(MAKE) PLAT=$(ATF_PLATFORM) $(bldstr) bl31 $$bl32opt $(LOG_MUTE)
	cp -f build/$(ATF_PLATFORM)/release/bl31.bin $(FBOUTDIR)/bsp/atf/$(MACHINE)/bl31-${ATF_PLATFORM}.bin
endef

define atf_ls
	[ -z "$1" ] && { $(call fbprint_e,"Boot type parameter is required"); exit 1; }
	bl33=$(FBOUTDIR)/bsp/u-boot/$(MACHINE)/output/$(uboot_cfg)/u-boot.bin
	[ -f "$$bl33" ] || { echo "Uboot does not exist."; exit 1; }
	if [ "$(CONFIG_SECURE_BOOT)" = y ]; then
		cp -f $(PKGDIR)/apps/security/cst/srk.* $(PKGDIR)/bsp/atf
	fi
	rcw_boot=rcw_"$1""$(RCWExt)"
	rcw_rel=$$(echo $${!rcw_boot} | tr -d '"')
	rcwbin="$(FBOUTDIR)/$$rcw_rel"
	[ -f "$$rcwbin" ] || { $(call fbprint_e,"$$rcwbin not exist"); exit 1; }
	if [ "$(CONFIG_FUSE_PROVISIONING)" = y ]; then
		fuseopt="fip_fuse FUSE_PROG=1 FUSE_PROV_FILE=$(PKGDIR)/apps/security/cst/fuse_scr.bin"
		(
			cd $(PKGDIR)/apps/security/cst
			./gen_fusescr input_files/gen_fusescr/$(CHASSIS_TYPE)/input_fuse_file $(LOG_MUTE)
		)
	fi
	if [ "$(CONFIG_OPTEE)" = y ]; then
		bl32opt="BL32=$(PKGDIR)/apps/security/optee_os/out/arm-plat-ls/core/tee_$(MACHINE).bin SPD=opteed"
	fi
	bootmode=$$( [ "$(1)" = xspi ] && echo flexspi_nor || echo "$(1)" )
	$(MAKE) fip pbl PLAT=$(MACHINE) BOOT_MODE=$$bootmode RCW=$$rcwbin BL33=$$bl33 $$bl32opt $(SECOpt) $$fuseopt $(bldstr) $(LOG_MUTE)
	if [ "$(CONFIG_SOC_LX2160ARDB)" = "y" -a "$(CONFIG_SECURE_BOOT)" = y ]; then
		$(MAKE) fip_ddr PLAT=$(MACHINE) BOOT_MODE=$$bootmode $(SECOpt) $(bldstr) $$fuseopt DDR_PHY_BIN_PATH=$(PKGDIR)/bsp/ddr_phy_bin/lx2160a $(LOG_MUTE)
		cp -f "build/$(MACHINE)/release/ddr_fip_sec.bin" "$(FBOUTDIR)/bsp/atf/$(MACHINE)/"
	fi
	cp -f build/$(MACHINE)/release/bl2_"$$bootmode"*.pbl "$(FBOUTDIR)/bsp/atf/$(MACHINE)/"
	cp -f build/$(MACHINE)/release/fip.bin $(FBOUTDIR)/bsp/atf/$(MACHINE)/fip_"$1""$(SECExt)".bin
	if [ "$(CONFIG_FUSE_PROVISIONING)" = "y" ]; then
		cp -f build/$(MACHINE)/release/fuse_fip.bin $(FBOUTDIR)/bsp/atf/$(MACHINE)/fuse_fip"$(SECExt)".bin
	fi
endef

fip.bin atf: $(ATF_DEPS)
	@$(call download_repo,atf,bsp)
	$(call patch_apply,atf,bsp)
	$(call fbprint_b,"ATF for $(MACHINE) $(ATF_SECINFO) $(ATF_OPTINFO) $(ATF_FUSEINFO)")
	cd $(BSPDIR)/atf
	mkdir -p $(FBOUTDIR)/bsp/atf/$(MACHINE)
	if [ "$(CONFIG_PLATFORM_IMX)" = "y" ]; then
		$(MAKE) realclean $(LOG_MUTE)
		$(call atf_imx)
	else
		boottypes=$$(echo $(BOOT_TYPE) | tr -d '"')
		for boottype in $$boottypes; do
			$(MAKE) realclean $(LOG_MUTE)
			$(call atf_ls,$$boottype) || exit 1
		done
	fi
	$(call fbprint_d,"ATF for $(MACHINE) $(ATF_SECINFO) $(ATF_OPTINFO) $(ATF_FUSEINFO) in: $(FBOUTDIR)/bsp/atf/$(MACHINE)")

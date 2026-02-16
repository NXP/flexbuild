#
# Copyright 2018-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#

# build ATF image for Layerscape and i.MX platforms

.PHONY: atf
bldstr = "BUILD_STRING=$(DEFAULT_REPO_TAG)"

ATF_DEPS =
ifdef CONFIG_OPTEE
	ATF_DEPS += optee_os
endif

ifdef CONFIG_SOC_IMX95
	ATF_DEPS += imx_sm imx_oei
endif

ifdef CONFIG_PLATFORM_LS
	ATF_DEPS += rcw uboot

	ifdef CONFIG_SECURE_BOOT
		ATF_DEPS += cst
		ifdef CONFIG_SOC_LX2160ARDB
			ATF_DEPS += ddr_phy_bin
		endif
	endif
endif

define atf_imx
	if [ "$(CONFIG_OPTEE)" = y ]; then \
		bl32=$(PKGDIR)/apps/security/optee_os/out/arm-plat-imx/core/tee_$(MACHINE).bin; \
		bl32opt="BL32=$$bl32" && spdopt="SPD=opteed"; \
	else \
		bl32opt="" && spdopt=""; \
	fi && \
	$(MAKE) -j$(JOBS) PLAT=$(ATF_PLATFORM) $(bldstr) bl31 $$bl32opt $$spdopt $(LOG_MUTE) && \
	mkdir -p $(FBOUTDIR)/bsp/atf/$(MACHINE) && \
	cp -f build/$(ATF_PLATFORM)/release/bl31.bin $(FBOUTDIR)/bsp/atf/$(MACHINE)/bl31-${ATF_PLATFORM}.bin
endef

define atf_ls
	bl33=$(FBOUTDIR)/bsp/u-boot/$(MACHINE)/output/$(uboot_cfg)/u-boot.bin && \
	if [ ! -f "$$bl33" ]; then \
		echo Uboot does not exist. && exit 1; \
	fi && \
	if [ "$(CONFIG_SOC_LS104)" = y ]; then \
		chassistype=ls104x_1012; \
	else \
		chassistype=ls2088_1088; \
	fi && \
	if [ "$(CONFIG_SECURE_BOOT)" = y ]; then \
		if [ $$chassistype = ls104x_1012 ]; then \
			rcwbin=`grep ^rcw_"$(1)"_sec= $(FBDIR)/configs/board/$(MACHINE).conf | cut -d'"' -f2`; \
		else \
			rcwbin=`grep ^rcw_"$(1)"= $(FBDIR)/configs/board/$(MACHINE).conf | cut -d'"' -f2`; \
		fi; \
		secureopt="TRUSTED_BOARD_BOOT=1 CST_DIR=$(PKGDIR)/apps/security/cst"; \
		secext=_sec; \
		cp -f $(PKGDIR)/apps/security/cst/srk.* $(PKGDIR)/bsp/atf; \
	else \
		rcwbin=`grep ^rcw_"$(1)"= $(FBDIR)/configs/board/$(MACHINE).conf | cut -d'"' -f2`; \
		secext=""; \
	fi && \
	if [ -z "$$rcwbin" ]; then \
		echo $(MACHINE) "$1"boot$$secext is not supported && exit 0; \
	fi && \
	rcwbin=$(FBOUTDIR)/$$rcwbin && \
	if [ ! -f $$rcwbin ]; then \
		$(call fbprint_e,"$$rcwbin not exist"); exit 1; \
	fi && \
	if [ "$(CONFIG_FUSE_PROVISIONING)" = y ]; then \
		fusefile=$(PKGDIR)/apps/security/cst/fuse_scr.bin && \
		fuseopt="fip_fuse FUSE_PROG=1 FUSE_PROV_FILE=$$fusefile" && \
		if [ ! -d $(PKGDIR)/apps/security/cst ]; then $(MAKE) cst; fi && \
		$(call fbprint_b,"dependent fuse_scr.bin") && \
		cd $(PKGDIR)/apps/security/cst && \
		./gen_fusescr input_files/gen_fusescr/$$chassistype/input_fuse_file && \
		cd -; \
	fi && \
	if [ "$(CONFIG_OPTEE)" = y ]; then \
		bl32=$(PKGDIR)/apps/security/optee_os/out/arm-plat-ls/core/tee_$(MACHINE).bin; \
		bl32opt="BL32=$$bl32" && spdopt="SPD=opteed"; \
	else \
		bl32opt="" && spdopt=""; \
	fi && \
	if [ "$(1)" = xspi ]; then \
		bootmode=flexspi_nor; \
	else \
		bootmode="$(1)"; \
	fi && \
	\
	$(MAKE) -j$(JOBS) fip pbl PLAT=$(MACHINE) BOOT_MODE=$$bootmode RCW=$$rcwbin BL33=$$bl33 $$bl32opt $$spdopt $$secureopt $$fuseopt $(bldstr) $(LOG_MUTE) && \
	if [ "$(CONFIG_SOC_LX2160ARDB)" = "y" -a "$(CONFIG_SECURE_BOOT)" = y ]; then \
		$(MAKE) -j$(JOBS) fip_ddr PLAT=$(MACHINE) BOOT_MODE=$$bootmode $$secureopt $(bldstr) $$fuseopt DDR_PHY_BIN_PATH=$(PKGDIR)/bsp/ddr_phy_bin/lx2160a $(LOG_MUTE); \
		cp -f build/$(MACHINE)/release/ddr_fip_sec.bin $(FBOUTDIR)/bsp/atf/$(MACHINE)/; \
	fi && \
	cp -f build/$(MACHINE)/release/bl2_"$$bootmode"*.pbl $(FBOUTDIR)/bsp/atf/$(MACHINE)/ && \
	cp -f build/$(MACHINE)/release/fip.bin $(FBOUTDIR)/bsp/atf/$(MACHINE)/fip_"$1"$$secext.bin && \
	if [ "$(CONFIG_FUSE_PROVISIONING)" = "y" ]; then \
		cp -f build/$(MACHINE)/release/fuse_fip.bin $(FBOUTDIR)/bsp/atf/$(MACHINE)/fuse_fip$$secext.bin; \
	fi
endef

atf: $(ATF_DEPS)
	@$(call download_repo,atf,bsp) && \
	$(call patch_apply,atf,bsp) && \
	if [ "$(CONFIG_SECURE_BOOT)" = y ]; then \
		sboot_info="[secure mode]"; \
	else \
		sboot_info=""; \
	fi && \
	if [ "$(CONFIG_OPTEE)" = y ]; then \
		optee_info="[OPTEE enabled]"; \
	else \
		optee_info=""; \
	fi && \
	$(call fbprint_b,"ATF for $(MACHINE) $${sboot_info} $${optee_info}"); \
	cd $(BSPDIR)/atf && \
	mkdir -p $(FBOUTDIR)/bsp/atf/$(MACHINE) && \
	if [ "$(CONFIG_PLATFORM_IMX)" = "y" ]; then \
		$(MAKE) realclean $(LOG_MUTE) && \
		$(call atf_imx); \
	else \
		boottypes=$$(echo $(BOOT_TYPE) | tr -d '"') && \
		for boottype in $$boottypes; do \
			$(MAKE) realclean $(LOG_MUTE); \
			$(call atf_ls,$$boottype) || exit 1; \
		done; \
	fi && \
	ls -l $(FBOUTDIR)/bsp/atf/$(MACHINE)/* ${LOG_MUTE} && \
	$(call fbprint_d,"ATF for $(MACHINE) $${sboot_info} $${optee_info} in: $(FBOUTDIR)/bsp/atf/$(MACHINE)")

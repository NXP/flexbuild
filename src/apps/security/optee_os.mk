# Copyright 2017-2023,2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



ifdef CONFIG_PLATFORM_IMX

ifeq ($(CONFIG_SOC_IMX8MP),y)
	OPTEE_BRD = mx8mpevk
else ifeq ($(CONFIG_SOC_IMX91),y)
	OPTEE_BRD = mx91evk
else ifeq ($(CONFIG_SOC_IMX93),y)
	OPTEE_BRD = mx93evk
else ifeq ($(CONFIG_SOC_IMX95),y)
	OPTEE_BRD = mx95evk
else
	OPTEE_BRD = $(shell bash -c 's="$(MACHINE)"; echo "$${s:1}"')
endif

endif

optee_os:
	@$(call download_repo,optee_os,apps/security)
	$(call patch_apply,optee_os,apps/security)
	$(call fbprint_b,"optee_os")
	cd $(SECDIR)/optee_os
	if [ "$(CONFIG_PLATFORM_LS)" = "y" ]; then
		 $(MAKE) CFG_ARM64_core=y PLATFORM=ls-$(MACHINE) ARCH=arm CFG_TEE_CORE_LOG_LEVEL=1 CFG_TEE_TA_LOG_LEVEL=0 $(LOG_MUTE)
		 mv out/arm-plat-ls/core/tee-raw.bin out/arm-plat-ls/core/tee_$(MACHINE).bin
		 mkdir -p $(DESTDIR)/usr/lib/optee_armtz
		 cp -f out/arm-plat-ls/export-ta_arm64/ta/*.ta $(DESTDIR)/usr/lib/optee_armtz/
	else
		 $(MAKE) PLATFORM=imx PLATFORM_FLAVOR=$(OPTEE_BRD) ARCH=arm CFG_TEE_TA_LOG_LEVEL=0 CFG_TEE_CORE_LOG_LEVEL=0 $(LOG_MUTE)
		 mv out/arm-plat-imx/core/tee-raw.bin out/arm-plat-imx/core/tee_$(MACHINE).bin $(LOG_MUTE)
		 mkdir -p $(DESTDIR)/usr/lib/optee_armtz
		 cp -f out/arm-plat-imx/export-ta_arm64/ta/*.ta $(DESTDIR)/usr/lib/optee_armtz/
	fi
	$(call fbprint_d,"optee_os")

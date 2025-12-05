# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



optee_os:
ifeq ($(CONFIG_OPTEE),y)
	@[ $(DESTARCH) != arm64  ] && exit || \
	 $(call download_repo,optee_os,apps/security) && \
	 $(call patch_apply,optee_os,apps/security) && \
	 $(call fbprint_b,"optee_os") && \
	 cd $(SECDIR)/optee_os && \
	 if [ $(SOCFAMILY) = LS ]; then \
		 $(MAKE) CFG_ARM64_core=y PLATFORM=ls-$(MACHINE) ARCH=arm \
			 CFG_TEE_CORE_LOG_LEVEL=1 CFG_TEE_TA_LOG_LEVEL=0 $(LOG_MUTE) && \
		 mv out/arm-plat-ls/core/tee-raw.bin out/arm-plat-ls/core/tee_$(MACHINE).bin && \
		 mkdir -p $(DESTDIR)/usr/lib/optee_armtz && \
		 cp -f out/arm-plat-ls/export-ta_arm64/ta/*.ta $(DESTDIR)/usr/lib/optee_armtz/ && \
		 if [ $(MACHINE) = ls1012afrwy ]; then \
		     mv out/arm-plat-ls/core/tee_$(MACHINE).bin out/arm-plat-ls/core/tee_$(MACHINE)_512mb.bin && \
		     $(MAKE) -j$(JOBS) CFG_ARM64_core=y PLATFORM=ls-ls1012afrwy ARCH=arm CFG_DRAM0_SIZE=0x40000000 $(LOG_MUTE) && \
		     mv out/arm-plat-ls/core/tee-raw.bin out/arm-plat-ls/core/tee_$(MACHINE).bin; \
		 fi; \
	elif [ $(SOCFAMILY) = IMX ]; then \
		case $(MACHINE) in \
			imx8mp*) brd=mx8mpevk; \
				;; \
			imx91*) brd=mx91evk; \
				;; \
			imx93*) brd=mx93evk; \
				;; \
			imx95*) brd=mx95evk; \
				;; \
			*)  brd=$${MACHINE:1}; \
				;; \
		esac && \
		 $(MAKE) PLATFORM=imx PLATFORM_FLAVOR=$$brd ARCH=arm CFG_TEE_TA_LOG_LEVEL=0 CFG_TEE_CORE_LOG_LEVEL=0 $(LOG_MUTE) && \
		 mv out/arm-plat-imx/core/tee-raw.bin out/arm-plat-imx/core/tee_$(MACHINE).bin $(LOG_MUTE) && \
		 mkdir -p $(DESTDIR)/usr/lib/optee_armtz && \
		 cp -f out/arm-plat-imx/export-ta_arm64/ta/*.ta $(DESTDIR)/usr/lib/optee_armtz/; \
	fi && \
	$(call fbprint_d,"optee_os")
endif

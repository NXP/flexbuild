# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



optee_os:
ifeq ($(CONFIG_OPTEE),y)
	@[ $(DESTARCH) != arm64 -o $(DISTROVARIANT) = tiny -o $(DISTROVARIANT) = base ] && exit || \
	 $(call download_repo,optee_os,apps/security) && \
	 $(call patch_apply,optee_os,apps/security) && \
	 $(call fbprint_b,"optee_os") && \
	 cd $(SECDIR)/optee_os && \
	 if [ $(SOCFAMILY) = LS ]; then \
		 brd=$(MACHINE); \
		 $(MAKE) CFG_ARM64_core=y PLATFORM=ls-$$brd ARCH=arm \
			 CFG_TEE_CORE_LOG_LEVEL=1 CFG_TEE_TA_LOG_LEVEL=0 $(LOG_MUTE) && \
		 mv out/arm-plat-ls/core/tee-raw.bin out/arm-plat-ls/core/tee_$${MACHINE:0:10}.bin && \
		 mkdir -p $(DESTDIR)/usr/lib/optee_armtz && \
		 cp -f out/arm-plat-ls/export-ta_arm64/ta/*.ta $(DESTDIR)/usr/lib/optee_armtz/ && \
		 if [ $(MACHINE) = ls1012afrwy ]; then \
		     mv out/arm-plat-ls/core/tee_$${MACHINE:0:10}.bin out/arm-plat-ls/core/tee_$${MACHINE:0:10}_512mb.bin && \
		     $(MAKE) -j$(JOBS) CFG_ARM64_core=y PLATFORM=ls-ls1012afrwy ARCH=arm CFG_DRAM0_SIZE=0x40000000 $(LOG_MUTE) && \
		     mv out/arm-plat-ls/core/tee-raw.bin out/arm-plat-ls/core/tee_$${MACHINE:0:10}.bin; \
		 fi; \
	elif [ $(SOCFAMILY) = IMX ]; then \
		 brd=$${MACHINE:1}; \
		 $(MAKE) PLATFORM=imx PLATFORM_FLAVOR=$$brd ARCH=arm CFG_TEE_TA_LOG_LEVEL=0 CFG_TEE_CORE_LOG_LEVEL=0 $(LOG_MUTE) && \
		 $(CROSS_COMPILE)objcopy -v -O binary out/arm-plat-imx/core/tee.elf out/arm-plat-imx/core/tee_$(MACHINE).bin $(LOG_MUTE) && \
		 mkdir -p $(DESTDIR)/usr/lib/optee_armtz && \
		 cp -f out/arm-plat-imx/export-ta_arm64/ta/*.ta $(DESTDIR)/usr/lib/optee_armtz/; \
	fi && \
	$(call fbprint_d,"optee_os")
endif

# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



optee_os:
ifeq ($(CONFIG_OPTEE), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -a $(DISTROTYPE) != yocto -o $(DISTROSCALE) = tiny -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"optee_os") && \
	 $(call repo-mngr,fetch,optee_os,apps/security) && \
	 if ! `pip3 show -q pycryptodomex`; then \
	     pip3 install pycryptodomex; \
	 fi && \
	 cd $(SECDIR)/optee_os && \
	 if [ $(SOCFAMILY) = LS ]; then \
		 if [ $(MACHINE) = ls1088ardb_pb ]; then \
		     brd=ls1088ardb; \
		 elif [ $(MACHINE) = lx2160ardb_rev2 ]; then \
		     brd=lx2160ardb; \
		 elif [ $(MACHINE) = lx2162aqds ]; then \
	             brd=lx2160aqds; \
		 elif [ $(MACHINE) = ls1046afrwy ]; then \
		     brd=ls1046ardb; \
		 elif [ $(MACHINE) = qemuarm64 -o $(MACHINE) = all ]; then \
		     brd=ls1028ardb; \
		 else \
		     brd=$(MACHINE); \
		 fi && \
		 $(MAKE) CFG_ARM64_core=y PLATFORM=ls-$$brd ARCH=arm \
		         CFG_TEE_CORE_LOG_LEVEL=1 CFG_TEE_TA_LOG_LEVEL=0 && \
		 mv out/arm-plat-ls/core/tee-raw.bin out/arm-plat-ls/core/tee_$${MACHINE:0:10}.bin && \
		 mkdir -p $(DESTDIR)/usr/lib/optee_armtz && \
		 cp -f out/arm-plat-ls/export-ta_arm64/ta/*.ta $(DESTDIR)/usr/lib/optee_armtz/ && \
		 if [ $(MACHINE) = ls1012afrwy ]; then \
		     mv out/arm-plat-ls/core/tee_$${MACHINE:0:10}.bin out/arm-plat-ls/core/tee_$${MACHINE:0:10}_512mb.bin && \
		     $(MAKE) -j$(JOBS) CFG_ARM64_core=y PLATFORM=ls-ls1012afrwy ARCH=arm CFG_DRAM0_SIZE=0x40000000 && \
		     mv out/arm-plat-ls/core/tee-raw.bin out/arm-plat-ls/core/tee_$${MACHINE:0:10}.bin; \
		 fi; \
	elif [ $(SOCFAMILY) = IMX ]; then \
		 if [ $(MACHINE) = qemuarm64 -o $(MACHINE) = all ]; then \
		     brd=mx8mpevk; \
		 else \
		     brd=$${MACHINE:1}; \
		 fi && \
		 $(MAKE) PLATFORM=imx PLATFORM_FLAVOR=$$brd ARCH=arm CFG_TEE_TA_LOG_LEVEL=0 CFG_TEE_CORE_LOG_LEVEL=0 && \
		 $(CROSS_COMPILE)objcopy -v -O binary out/arm-plat-imx/core/tee.elf out/arm-plat-imx/core/tee_$(MACHINE).bin && \
		 mkdir -p $(DESTDIR)/usr/lib/optee_armtz && \
		 cp -f out/arm-plat-imx/export-ta_arm64/ta/*.ta $(DESTDIR)/usr/lib/optee_armtz/; \
	fi && \
	$(call fbprint_d,"optee_os")
endif
endif

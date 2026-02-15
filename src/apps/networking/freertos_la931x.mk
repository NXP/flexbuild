# Copyright 2023-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
CONFIG_APP_FREERTOS_LA931X ?= n

freertos_la931x:
	@set -e; \
	if [ "$(strip $(CONFIG_APP_FREERTOS_LA931X))" != "y" ]; then \
		echo "Skipping freertos_la931x: CONFIG_APP_FREERTOS_LA931X!='y' (current='$(strip $(CONFIG_APP_FREERTOS_LA931X))')"; \
		exit 0; \
	fi && \
	$(call download_repo,freertos_la931x,apps/networking,git) && \
	$(call patch_apply,freertos_la931x,apps/networking) && \
	if [ ! -d $(NETDIR)/gcc-arm-none-eabi-10.3-2021.10 ]; then  \
		cd $(NETDIR) && \
		wget --no-check-certificate $(repo_m4_gcc_url) && bzip2 -dk gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar.bz2 && \
		tar -xvf gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar && \
		rm -rf gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar.bz2 && rm -rf gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar; fi && \
	$(call fbprint_b,"freertos_la931x") && \
	export ARMGCC_DIR=$(NETDIR)/gcc-arm-none-eabi-10.3-2021.10 && \
	cd $(NETDIR)/freertos_la931x/Demo/CORTEX_M4_NXP_LA9310_GCC/ && \
	./clean.sh && ./build_release.sh -boot_mode=pcie && \
	mkdir -p $(DESTDIR)/lib/firmware/ && \
	cp -f release/* $(DESTDIR)/lib/firmware/ && \
	cd $(NETDIR)//freertos_la931x/Demo/CORTEX_M4_NXP_LA9310_GCC/ && \
	./clean.sh && ./build_release.sh -boot_mode=i2c && \
	cp -f release/* $(NETDIR)/freertos_la931x/standalone_utils/firmware && \
	 $(call fbprint_d,"freertos_la931x")

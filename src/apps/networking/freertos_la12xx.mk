# Copyright 2023-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
CONFIG_APP_FREERTOS_LA12XX ?= n

freertos_la12xx:
	@set -e; \
	if [ "$(strip $(CONFIG_APP_FREERTOS_LA12XX))" != "y" ]; then \
		echo "Skipping freertos_la12xx: CONFIG_APP_FREERTOS_LA12XX!='y' (current='$(strip $(CONFIG_APP_FREERTOS_LA12XX))')"; \
		exit 0; \
	fi && \
	$(call download_repo,freertos_la12xx,apps/networking,git) && \
	$(call patch_apply,freertos_la12xx,apps/networking) && \
	if [ ! -d $(NETDIR)/geul_common_headers ]; then $(call download_repo,geul_common_headers,apps/networking); fi && \
	if [ ! -d $(NETDIR)/gcc-4.9.4-Ee200-eabivle ]; then  \
	        cd $(NETDIR) && \
		curl -R -O -f https://www.nxp.com/lgfiles/geul/Tools/gcc-4.9.4-Ee200-eabivle-x86_64-linux-g2724867.tar.bz2 && bzip2 -dk gcc-4.9.4-Ee200-eabivle-x86_64-linux-g2724867.tar.bz2 && \
		tar -xvf gcc-4.9.4-Ee200-eabivle-x86_64-linux-g2724867.tar && \
		rm -rf gcc-4.9.4-Ee200-eabivle-x86_64-linux-g2724867.tar.bz2 && rm -rf gcc-4.9.4-Ee200-eabivle-x86_64-linux-g2724867.tar; fi && \
	$(call fbprint_b,"freertos_la12xx") && \
	export COMMON_HEADERS_DIR=$(NETDIR)/geul_common_headers && \
	export E200GCC_DIR=$(NETDIR)/gcc-4.9.4-Ee200-eabivle/x86_64-linux && \
	export PATH=$(PATH):$(E200GCC_DIR)/bin && \
	mkdir -p $(DESTDIR)/lib/firmware/ && \
	cd $(NETDIR)/freertos_la12xx/demos/E200_MPC57XXX_GEUL_GCC && \
	./clean.sh && ./build.sh -t la1246 -l info -b debug -m pci && \
	cp -f release/geul_e200.elf $(DESTDIR)/lib/firmware/geul_e200_la1246.elf && \
	cd $(NETDIR)/freertos_la12xx/demos/E200_MPC57XXX_GEUL_GCC && \
	if [ $${MACHINE:0:6} = la1238 ]; then \
		./clean.sh && ./build.sh -t la1238rdb -l info -b release -m pci; \
		else \
		./clean.sh && ./build.sh -t la1224 -l info -b release -m pci;  \
	fi && \
	cp -f release/geul_e200.elf $(DESTDIR)/lib/firmware/geul_e200_rel.elf && \
	cd $(NETDIR)/freertos_la12xx/demos/E200_MPC57XXX_GEUL_GCC && \
	if [ $${MACHINE:0:6} = la1224 ]; then \
		./clean.sh && ./build.sh -t la1224 -l info -b release -m pci -f LA12XX_FEATURE_WARMUP=ON; \
	fi && \
	cp -f release/geul_e200.elf $(DESTDIR)/lib/firmware/geul_e200_warmup.elf && \
	cd $(NETDIR)/freertos_la12xx/demos/E200_MPC57XXX_GEUL_GCC && \
	./clean.sh && ./build.sh -t la1224 -l info -b release -m pci -f LA12XX_FEATURE_RUDEMO=ON && \
	cp -f release/geul_e200.elf $(DESTDIR)/lib/firmware/geul_e200_rudemo.elf && \
	cd $(NETDIR)/freertos_la12xx/demos/E200_MPC57XXX_GEUL_GCC && \
	./clean.sh && ./build.sh -t la1224 -l info -b release -m pci -f LA12XX_FEATURE_L1C_REFAPP=ON && \
	cp -f release/geul_e200.elf $(DESTDIR)/lib/firmware/geul_e200_l1c_refapp.elf && \
	cd $(NETDIR)/freertos_la12xx/demos/E200_MPC57XXX_GEUL_GCC && \
	./clean.sh && ./build.sh -t la1224 -l info -b release -m pci -f LA12XX_FEATURES=ON -f LA12XX_FEATURE_DU_ONLY=ON && \
	cp -f release/geul_e200.elf $(DESTDIR)/lib/firmware/geul_e200_du.elf && \
	cd $(NETDIR)/freertos_la12xx/demos/E200_MPC57XXX_GEUL_GCC && \
	./clean.sh && ./build.sh -t la1224 -l info -b release -m pci -f LA12XX_FEATURES=ON -f LA12XX_DRIVER_PCI=ON && \
	cp -f release/geul_e200.elf $(DESTDIR)/lib/firmware/geul_e200_pci.elf && \
	cd $(NETDIR)/freertos_la12xx/demos/E200_MPC57XXX_GEUL_GCC && \
	if [ $${MACHINE:0:6} = la1238 ]; then \
		./clean.sh && ./build.sh -t la1238rdb -l info -b debug -m pci; \
		else \
		./clean.sh && ./build.sh -t la1224 -l info -b debug -m pci;  \
	fi && \
	cp -f release/*.elf $(DESTDIR)/lib/firmware && \
	$(call fbprint_d,"freertos_la12xx")

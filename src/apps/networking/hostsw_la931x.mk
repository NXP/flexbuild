# Copyright 2023-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
CONFIG_APP_HOSTSW_LA931X ?= n

hostsw_la931x:
	@set -e; \
	if [ "$(strip $(CONFIG_APP_HOSTSW_LA931X))" != "y" ]; then \
		echo "Skipping hostsw_la931x: CONFIG_APP_HOSTSW_LA931X!='y' (current='$(strip $(CONFIG_APP_HOSTSW_LA931X))')"; \
		exit 0; \
	fi && \
	$(call download_repo,hostsw_la931x,apps/networking,git) && \
	$(call patch_apply,hostsw_la931x,apps/networking) && \
        curbrch=$(KERNEL_BRANCH) && \
        kerneloutdir=$(KERNEL_OUTPUT_PATH)/$$curbrch && \
        kernelrelease=`cat $$kerneloutdir/include/config/kernel.release` && \
	if [ ! -d $(NETDIR)/freertos_la931x ]; then $(call download_repo,freertos_la931x,apps/networking); fi && \
	$(call fbprint_b,"hostsw_la931x") && \
	cd $(NETDIR)/hostsw_la931x && export CROSS=$(CROSS_COMPILE) && \
	export KERNEL_DIR=$(KERNEL_OUTPUT_PATH)/$$curbrch && \
	export LA9310_COMMON_HEADERS=$(NETDIR)/freertos_la931x/common_headers && \
	if [ $${MACHINE:0:6} = la1238 ]; then \
		$(MAKE) LA1238RDB=1 $(LOG_MUTE) && $(MAKE) install; \
		else \
		$(MAKE) LA1224=1 $(LOG_MUTE) && $(MAKE) install; \
	fi && \
	mkdir -p $(KERNEL_OUTPUT_PATH)/$$curbrch/tmp/lib/modules/$$kernelrelease/extra && \
	cp -f install/kernel_module/* $(KERNEL_OUTPUT_PATH)/$$curbrch/tmp/lib/modules/$$kernelrelease/extra/ && \
	mkdir -p $(DESTDIR)/lib/firmware/ && \
	mkdir -p $(DESTDIR)/usr/lib/ && \
	cp -rf install/lib/firmware/apm.eld $(DESTDIR)/lib/firmware/ && \
	cp -rf install/usr/lib/* $(DESTDIR)/usr/lib/ && \
	cp -rf install/usr/bin/* $(DESTDIR)/usr/bin/ && \
	$(call fbprint_d,"hostsw_la931x")

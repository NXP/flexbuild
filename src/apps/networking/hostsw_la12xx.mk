# Copyright 2023-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
CONFIG_APP_HOSTSW_LA12XX ?= n

hostsw_la12xx:
	@set -e; \
	if [ "$(strip $(CONFIG_APP_HOSTSW_LA12XX))" != "y" ]; then \
		echo "Skipping hostsw_la12xx: CONFIG_APP_HOSTSW_LA12XX!='y' (current='$(strip $(CONFIG_APP_HOSTSW_LA12XX))')"; \
		exit 0; \
	fi && \
	$(call download_repo,hostsw_la12xx,apps/networking,git) && \
	$(call patch_apply,hostsw_la12xx,apps/networking) && \
        curbrch=$(KERNEL_BRANCH) && \
        kerneloutdir=$(KERNEL_OUTPUT_PATH)/$$curbrch && \
        kernelrelease=`cat $$kerneloutdir/include/config/kernel.release` && \
	if [ ! -d $(NETDIR)/geul_common_headers ]; then $(call download_repo,geul_common_headers,apps/networking); fi && \
	$(call fbprint_b,"hostsw_la12xx") && \
	cd $(NETDIR)/hostsw_la12xx && export CROSS=$(CROSS_COMPILE) && \
	export KERNEL_DIR=$(KERNEL_OUTPUT_PATH)/$$curbrch && export COMMON_HEADERS_DIR=$(NETDIR)/geul_common_headers && \
	export DPDK_DIR=$(NETDIR)/dpdk && \
	if [ $${MACHINE:0:6} = la1238 ]; then \
		$(MAKE) LA1238RDB=1 $(LOG_MUTE) && $(MAKE) install; \
		else \
		$(MAKE) LA1224=1 $(LOG_MUTE) && $(MAKE) install; \
	fi && \
	mkdir -p $(KERNEL_OUTPUT_PATH)/$$curbrch/tmp/lib/modules/$$kernelrelease/extra && \
	cp -f install/kernel_module/* $(KERNEL_OUTPUT_PATH)/$$curbrch/tmp/lib/modules/$$kernelrelease/extra/ && \
	mkdir -p $(DESTDIR)/lib/firmware/ && \
	mkdir -p $(DESTDIR)/usr/lib/ && \
	if [[ ! -e $(DESTDIR)/root ]]; then  mkdir $(DESTDIR)/root; fi && \
	mkdir -p $(DESTDIR)/root/scripts/ && \
	cp -rf scripts/SINAD.py $(DESTDIR)/root/scripts && \
	cp -rf scripts/*.sh $(DESTDIR)/root/scripts && \
	cp -rf scripts/sysconfig.dat $(DESTDIR)/root/scripts && \
	cp -rf install/lib/firmware/vspa-pebm-*.eld $(DESTDIR)/lib/firmware/ && \
	cp -rf install/lib/firmware/geul-vspa*.eld $(DESTDIR)/lib/firmware/ && \
	cp -rf install/lib/firmware/*.bin $(DESTDIR)/lib/firmware/ && \
	cp -rf install/lib/firmware/*.mem $(DESTDIR)/lib/firmware/ && \
	cp -rf install/usr/lib/* $(DESTDIR)/usr/lib/ && \
	cp -rf install/usr/bin/* $(DESTDIR)/usr/bin/ && \
	cp -rf license/EULA.txt $(DESTDIR)/lib/firmware/ && \
	cp -rf firmware/bsp_version $(DESTDIR)/lib/firmware/
	$(call fbprint_d,"hostsw_la12xx")

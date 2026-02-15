# Copyright 2024-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

dpdk_extras:
	$(call download_repo,dpdk_extras,apps/networking,git) && \
	if [ "$(RELEASE_TYPE)" = "external" ]; then \
		$(call patch_apply,dpdk_extras,apps/networking); \
	fi && \
	$(call fbprint_b,"dpdk_extras") && \
	if [ ! -d $(DESTDIR)/usr/local/dpdk ]; then \
	     bld dpdk -m $(MACHINE); \
	 fi && \
	curbrch=$(KERNEL_BRANCH) && \
        kerneloutdir=$(KERNEL_OUTPUT_PATH)/$$curbrch && \
        kernelrelease=`cat $$kerneloutdir/include/config/kernel.release` && \
	cd $(NETDIR)/dpdk_extras && export CROSS=$(CROSS_COMPILE) && \
	export DPDKDIR=$(NETDIR)/dpdk && \
	export KSRC=$(KERNEL_OUTPUT_PATH)/$$curbrch && export ARCH=arm64 && \
	cd linux; $(MAKE) && $(MAKE) install; \
	cd lsxinic; $(MAKE) && $(MAKE) install; cd ..;\
	mkdir -p $(KERNEL_OUTPUT_PATH)/$$curbrch/tmp/lib/modules/$$kernelrelease/extra && \
	cp -f install/*.ko $(KERNEL_OUTPUT_PATH)/$$curbrch/tmp/lib/modules/$$kernelrelease/extra/ && \
	$(call fbprint_d,"dpdk_extras")

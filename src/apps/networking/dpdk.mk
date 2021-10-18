# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



# cross build DPDK against Ubuntu or Yocto userland


DPDK_EXAMPLES = "l2fwd,l3fwd,l2fwd-qdma,ip_fragmentation,ip_reassembly,qdma_demo,ethtool,link_status_interrupt,multi_process/symmetric_mp,multi_process/simple_mp,multi_process/symmetric_mp_qdma,kni,ipsec-secgw,qos_sched,multi_process/client_server_mp/mp_server,multi_process/client_server_mp/mp_client,l3fwd-power,l2fwd-event,l2fwd-crypto,bond"



dpdk:
ifeq ($(CONFIG_DPDK), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -a $(DISTROTYPE) != debian -a $(DISTROTYPE) != yocto -o $(DISTROSCALE) = desktop -o \
	   $(DISTROSCALE) = lite -o $(DISTROSCALE) = tiny ] && exit || \
	 $(call fbprint_b,"dpdk") && \
	 $(call repo-mngr,fetch,dpdk,apps/networking) && \
	 if [ ! -d $(RFSDIR)/usr/lib ]; then \
	     bld -i mkrfs -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/local/lib/libcrypto.so ]; then \
	     bld -c openssl -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 curbrch=`cd $(KERNEL_PATH) && git branch | grep ^* | cut -d' ' -f2` && \
	 if [ ! -f $(KERNEL_OUTPUT_PATH)/$$curbrch/.config ]; then \
	     bld -c linux -a $(DESTARCH) -p $(SOCFAMILY) -f $(CFGLISTYML); \
	 fi && \
	 sudo mkdir -p $(RFSDIR)/usr/local/lib && \
	 sudo cp -af $(DESTDIR)/usr/local/lib/libcrypto.so* $(RFSDIR)/usr/local/lib/ && \
	 cd $(NETDIR)/dpdk && \
	 export PKG_CONFIG_PATH=$(DESTDIR)/usr/local/lib/pkgconfig:$(PKG_CONFIG_PATH) && \
	 build_dir=build_arm64_$(DISTROTYPE)_$(DISTROSCALE) && \
	 PKG_CONFIG_SYSROOT_DIR=$(RFSDIR) \
	 meson $$build_dir --prefix=/usr/local --buildtype=release \
		-Denable_kmods=true \
		-Dkernel_dir=$(KERNEL_OUTPUT_PATH)/$$curbrch \
		-Dexamples=$(DPDK_EXAMPLES) \
		-Dc_args="-Ofast -fPIC -ftls-model=local-dynamic -I$(DESTDIR)/usr/local/include" \
		-Doptimization=3 \
		--cross-file=config/arm/arm64_dpaa_linux_gcc && \
	 DESTDIR=$(DESTDIR) ninja -j $(JOBS) -C $$build_dir install && \
	 cd $$build_dir/examples && find . -perm -111 -a -type f | xargs -I {} cp {} $(DESTDIR)/usr/local/bin && \
	 cd - && mkdir -p $(DESTDIR)/usr/local/dpdk && \
	 cp -rf $(NETDIR)/dpdk/nxp/* $(DESTDIR)/usr/local/dpdk && \
	 cp -t $(DESTDIR)/usr/local/include config/rte_config.h $$build_dir/rte_build_config.h lib/librte_mempool/rte_*.h \
	    lib/librte_ethdev/rte_*.h lib/librte_cryptodev/rte_*.h lib/librte_ring/rte_*.h \
	    lib/librte_mbuf/rte_mbuf.h lib/librte_eal/linux/include/rte_*.h && \
	 cp -rf lib/librte_eal/include/generic $(DESTDIR)/usr/local/include && \
	 cp -f $$build_dir/kernel/linux/kni/rte_kni.ko $(DESTDIR)/usr/local/dpdk && \
	 rm -rf $(DESTDIR)/usr/local/share/dpdk/examples && \
	 $(call fbprint_d,"dpdk")
endif
endif

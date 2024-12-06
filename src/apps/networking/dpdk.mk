# Copyright 2017-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# cross compile DPDK against Debian/Ubuntu userland

# depends on libssl-dev for libcrypto.so

# choose some extra examples to build
# DPDK_EXAMPLES = all
# DPDK_EXAMPLES = "l2fwd,l3fwd,ip_fragmentation,ip_reassembly,qdma_demo,ethtool,link_status_interrupt,multi_process/symmetric_mp,multi_process/simple_mp,ipsec-secgw,qos_sched,multi_process/client_server_mp/mp_server,multi_process/client_server_mp/mp_client,l3fwd-power,l2fwd-event,l2fwd-crypto,bond"

DPDK_EXAMPLES = "l2fwd,l3fwd,ip_fragmentation,ip_reassembly,qdma_demo,ethtool"


dpdk:
	@[ $(DISTROVARIANT) = base -o $(DISTROVARIANT) = tiny ] && exit || \
	 $(call fbprint_b,"dpdk") && \
	 $(call repo-mngr,fetch,dpdk,apps/networking) && \
	 $(call repo-mngr,fetch,linux,linux) && \
	 if [ ! -d $(RFSDIR)/usr/lib ]; then \
	     bld rfs -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 curbrch=`cd $(KERNEL_PATH) && git branch | grep ^* | cut -d' ' -f2` && \
	 if [ ! -f $(KERNEL_OUTPUT_PATH)/$$curbrch/.config ]; then \
	     bld linux -a $(DESTARCH) -p $(SOCFAMILY); \
	 fi && \
	 \
	 cd $(NETDIR)/dpdk && \
	 build_dir=build_$(DISTROTYPE)_$(ARCH) && \
	 meson setup $$build_dir \
	 	--prefix=/usr --buildtype=release \
		--strip \
		-Denable_kmods=false \
		-Dkernel_dir=$(KERNEL_OUTPUT_PATH)/$$curbrch \
		-Dexamples=$(DPDK_EXAMPLES) \
		-Dc_args="-Ofast -fPIC -ftls-model=local-dynamic -Wno-error=implicit-function-declaration -I$(DESTDIR)/usr/include" \
		-Doptimization=3 \
		--cross-file=config/arm/arm64_dpaa_linux_gcc && \
	 DESTDIR=$(DESTDIR) ninja -j $(JOBS) -C $$build_dir install && \
	 cd $$build_dir/examples && find . -perm -111 -a -type f | xargs -I {} cp {} $(DESTDIR)/usr/local/bin && \
	 cd - && mkdir -p $(DESTDIR)/usr/local/dpdk && \
	 cp -rf $(NETDIR)/dpdk/nxp/* $(DESTDIR)/usr/local/dpdk && \
	 cp -f $(NETDIR)/dpdk/drivers/bus/pci/bus_pci_driver.h $(DESTDIR)/usr/include && \
	 $(CROSS_COMPILE)strip $(DESTDIR)/usr/local/bin/dpdk-* && \
	 ln -sf $$build_dir/rte_build_config.h rte_build_config.h && \
	 $(call fbprint_d,"dpdk")

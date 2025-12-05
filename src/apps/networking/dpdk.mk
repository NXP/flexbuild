# Copyright 2017-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# cross compile DPDK against Debian/Ubuntu userland

# depends on libssl-dev for libcrypto.so

# choose some extra examples to build
# DPDK_EXAMPLES = all
# DPDK_EXAMPLES = "l2fwd,l3fwd,ip_fragmentation,ip_reassembly,qdma_demo,ethtool,link_status_interrupt,multi_process/symmetric_mp,multi_process/simple_mp,ipsec-secgw,qos_sched,multi_process/client_server_mp/mp_server,multi_process/client_server_mp/mp_client,l3fwd-power,l2fwd-event,l2fwd-crypto,bond"

DPDK_EXAMPLES = "l2fwd,l3fwd,ip_fragmentation,ip_reassembly,qdma_demo,ethtool,ipsec-secgw,l2fwd-crypto"
DPDK_APPS = pdump,test-pmd,proc-info,test-crypto-perf

dpdk:
	 @$(call download_repo,dpdk,apps/networking) && \
	 $(call patch_apply,dpdk,apps/networking) && \
	 if [ ! -d $(RFSDIR)/usr/lib ]; then \
	     bld rfs -m $(MACHINE); \
	 fi && \
	 if [ ! -f $(KERNEL_OUTPUT_PATH)/$(KERNEL_BRANCH)/.config ]; then \
	     bld linux -m $(MACHINE); \
	 fi && \
	 \
	 $(call fbprint_b,"dpdk") && \
	 export PKG_CONFIG_PATH=$(RFSDIR)/usr/lib/pkgconfig:$(RFSDIR)/usr/share/pkgconfig && \
	 export PKG_CONFIG_SYSROOT_DIR=$(RFSDIR) && \
	 export PKG_CONFIG_LIBDIR=$(RFSDIR)/usr/lib/aarch64-linux-gnu/pkgconfig:$(RFSDIR)/usr/lib/pkgconfig && \
	 export LIBRARY_PATH="$(RFSDIR)/usr/lib/aarch64-linux-gnu:$(RFSDIR)/usr/lib:$$LIBRARY_PATH" && \
	 export LD_LIBRARY_PATH="$(RFSDIR)/usr/lib/aarch64-linux-gnu:$(RFSDIR)/usr/lib:$$LD_LIBRARY_PATH" && \
	 cd $(NETDIR)/dpdk && \
	 build_dir=build_$(DISTROTYPE)_$(ARCH) && \
	 rm -rf $$build_dir && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
		-e 's%@DESTDIR@%$(DESTDIR)%g' $(FBDIR)/src/system/meson.cross > meson.cross && \
	 sed -i 's/-march=armv8-a+crc+crypto/-march=armv8-a/g' meson.cross && \
	 sed -i "s/cpu = 'aarch64'/cpu = 'armv8-a'/g" meson.cross && \
	 sed -i "/pkg_config_sysroot/a\platform = 'dpaa'" meson.cross && \
	 meson setup $$build_dir \
		--prefix=/usr \
		--strip \
		-Denable_kmods=false \
		-Dkernel_dir=$(KERNEL_OUTPUT_PATH)/$(KERNEL_BRANCH) \
		-Dexamples=$(DPDK_EXAMPLES) \
		-Dc_args="-Ofast -fPIC -ftls-model=local-dynamic -Wno-error=implicit-function-declaration -I$(DESTDIR)/usr/include" \
		-Dc_link_args="-L$(RFSDIR)/usr/lib/aarch64-linux-gnu -L$(RFSDIR)/usr/lib -Wl,-rpath-link,$(RFSDIR)/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,$(RFSDIR)/usr/lib" \
		-Doptimization=3 \
		-Denable_apps=$(DPDK_APPS) \
		-Denable_examples_source_install=false \
		-Denable_driver_sdk=true \
		-Ddrivers_install_subdir= \
		--cross-file=meson.cross $(LOG_MUTE) && \
	 DESTDIR=$(DESTDIR) ninja -j $(JOBS) -C $$build_dir install $(LOG_MUTE) && \
	 cd $$build_dir/examples && find . -perm -111 -a -type f | xargs -I {} cp {} $(DESTDIR)/usr/local/bin && \
	 cd - $(LOG_MUTE) && mkdir -p $(DESTDIR)/usr/local/dpdk && \
	 cp -rf $(NETDIR)/dpdk/nxp/* $(DESTDIR)/usr/local/dpdk && \
	 cp -f $(NETDIR)/dpdk/drivers/bus/pci/bus_pci_driver.h $(DESTDIR)/usr/include && \
	 $(CROSS_COMPILE)strip $(DESTDIR)/usr/local/bin/dpdk-* && \
	 ln -sf $$build_dir/rte_build_config.h rte_build_config.h && \
	 $(call fbprint_d,"dpdk")

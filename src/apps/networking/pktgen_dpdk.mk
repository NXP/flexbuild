# Copyright 2017-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
CONFIG_APP_PKTGEN_DPDK ?= n

pktgen_dpdk:
	@set -e; \
	if [ "$(strip $(CONFIG_APP_PKTGEN_DPDK))" != "y" ]; then \
		echo "Skipping pktgen_dpdk: CONFIG_APP_PKTGEN_DPDK!='y' (current='$(strip $(CONFIG_APP_PKTGEN_DPDK))')"; \
		exit 0; \
	fi && \
	[ $(SOCFAMILY) != LS -o $(DISTROVARIANT) != server ] && exit || \
	 $(call download_repo,pktgen_dpdk,apps/networking, git) && \
	 $(call patch_apply,pktgen_dpdk,apps/networking) && \
	 if [ ! -d $(RFSDIR)/usr/lib/aarch64-linux-gnu ]; then \
	     bld rfs -m $(MACHINE); \
	 fi && \
	 if [ ! -d $(DESTDIR)/usr/local/dpdk ]; then \
		bld dpdk -m $(MACHINE) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -f $(RFSDIR)/usr/include/rte_config.h ]; then \
		sudo cp -Pf $(DESTDIR)/usr/include/rte_*.h $(RFSDIR)/usr/include/ && \
		sudo cp -rf $(DESTDIR)/usr/include/generic $(RFSDIR)/usr/include/; \
	 fi && \
	 if [ ! -f $(RFSDIR)usr/lib/libbsd.a ]; then \
		bld bsd -m $(MACHINE) -f $(CFGLISTYML);  \
	 fi && \
	 \
	 $(call fbprint_b,"pktgen_dpdk") && \
	 cd $(NETDIR)/pktgen_dpdk && \
	 rm -rf build_$(DISTROTYPE)_$(ARCH) && \
	 export RTE_TARGET=arm64-dpaa-linuxapp-gcc && export RTE_SDK=$(DESTDIR)/usr/share/dpdk && \
	 sed -i "/add_project_arguments('-march=native'/s/^/#&/" meson.build && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     -e 's%@DESTDIR@%$(DESTDIR)%g' $(FBDIR)/src/system/meson.cross > meson.cross && \
	 sed -i 's/-march=armv8-a+crc+crypto/-march=armv8-a/g' meson.cross && \
	 sudo cp -ra $(DESTDIR)/usr/lib/librte* $(RFSDIR)/usr/lib/ && \
	 build_dir=build_$(DISTROTYPE)_$(ARCH) && \
	 export PKG_CONFIG_LIBDIR="$(RFSDIR)/usr/lib/aarch64-linux-gnu/pkgconfig:$(RFSDIR)/usr/lib/pkgconfig:$(RFSDIR)/usr/share/pkgconfig" && \
	 export PKG_CONFIG_SYSROOT_DIR="$(RFSDIR)" && \
	 \
	 meson setup $$build_dir \
		-Dc_args="-DRTE_FORCE_INTRINSICS -I$(DESTDIR)/usr/include -Wno-error=mismatched-dealloc \
			  -Wno-error=nonnull -Wno-error=implicit-function-declaration \
			  -Wno-error=unused-variable -Wno-error=format \
			  -Wno-error=packed-not-aligned \
			  -include rte_compat.h" \
		-Dc_link_args="-L$(DESTDIR)/usr/lib -L$(RFSDIR)/usr/lib -L$(RFSDIR)/lib/aarch64-linux-gnu" \
		--prefix=$(DESTDIR)/usr --buildtype=release \
		--cross-file meson.cross -Dwerror=false $(LOG_MUTE) && \
	 DESTDIR=$(DESTDIR) ninja -j $(JOBS) -C $$build_dir $(LOG_MUTE) && \
	 install -m 755 $$build_dir/app/pktgen Pktgen.lua ${DESTDIR}/usr/bin && \
	 $(call fbprint_d,"pktgen_dpdk")

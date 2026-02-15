# Copyright 2017-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
CONFIG_APP_DPDK_NFP ?= n
dpdk_nfp:
ifeq ($(CONFIG_APP_DPDK_NFP), "y")
	@[ $(SOCFAMILY) != LS -o $(DISTROVARIANT) != server ] && exit || \
	 $(call download_repo,dpdk_nfp,apps/networking,git) && \
	 $(call patch_apply,dpdk_nfp,apps/networking) && \
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
	 \
	 $(call fbprint_b,"dpdk_nfp") && \
        cd $(NETDIR)/dpdk_nfp && \
	export CROSS=$(CROSS_COMPILE) && \
	export CC="$(CROSS_COMPILE)gcc" && \
	export CXX=$(CROSS_COMPILE)g++ && \
	export SYSROOT="$(RFSDIR)" && \
	export CFLAGS="--sysroot=$$SYSROOT" && \
	export CXXFLAGS="--sysroot=$$SYSROOT" && \
	export LDFLAGS="--sysroot=$$SYSROOT \
		-Wl,-rpath-link,$$SYSROOT/lib/aarch64-linux-gnu \
		-Wl,-rpath-link,$$SYSROOT/usr/lib/aarch64-linux-gnu \
		-L$(DESTDIR)/usr/lib -L$(RFSDIR)/usr/lib -L$(RFSDIR)/lib/aarch64-linux-gnu" && \
	export PKG_CONFIG_EXECUTABLE=/usr/bin/pkg-config && \
	export PKG_CONFIG_SYSROOT_DIR="$$SYSROOT" && \
	export PKG_CONFIG_PATH="$(DESTDIR)/usr/lib/aarch64-linux-gnu/pkgconfig:$(DESTDIR)/usr/lib/pkgconfig:$(DESTDIR)/usr/share/pkgconfig" && \
	export PKG_CONFIG_LIBDIR="$(DESTDIR)/usr/lib/aarch64-linux-gnu/pkgconfig:$(DESTDIR)/usr/lib/pkgconfig" && \
	build_dir=build_$(DISTROTYPE)_$(ARCH) && \
	rm -rf $$build_dir && \
	cmake -S . -B $$build_dir \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_SYSTEM_NAME=Linux \
		-DCMAKE_SYSTEM_PROCESSOR=aarch64 \
		-DCMAKE_C_COMPILER=$(CROSS_COMPILE)gcc \
		-DCMAKE_CXX_COMPILER=$(CROSS_COMPILE)g++ \
		-DCMAKE_SYSROOT="$$SYSROOT" \
		-DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY \
		-DCMAKE_C_COMPILER_WORKS=1 \
		-DCMAKE_CXX_COMPILER_WORKS=1 \
		-DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
		-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
		-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
		-DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY \
		-DDPDK_INSTALL=$(DESTDIR)/usr/ \
		-DDPDK_INCLUDE_DIRS=$(NETDIR)/dpdk/examples/common/ \
		-DCMAKE_PREFIX_PATH="$(DESTDIR)/usr" \
		-DCMAKE_EXE_LINKER_FLAGS="-Wl,-rpath-link,$$SYSROOT/lib/aarch64-linux-gnu -Wl,-rpath-link,$$SYSROOT/usr/lib/aarch64-linux-gnu" && \
	$(MAKE) -C $$build_dir -j$(JOBS) 'CFLAGS=-g -Ofast' && \
	cp -f $(NETDIR)/dpdk_nfp/$$build_dir/lib/libnfp.a $(DESTDIR)/usr/local/lib && \
	cp -f $(NETDIR)/dpdk_nfp/$$build_dir/lib/libnfp.so $(DESTDIR)/usr/local/lib && \
	$(call fbprint_d,"dpdk_nfp")
endif

# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



pktgen_dpdk:
ifeq ($(CONFIG_PKTGEN_DPDK), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(SOCFAMILY) != LS -o $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = desktop -o \
	   $(DISTROSCALE) = lite -o $(DISTROSCALE) = tiny ] && exit || \
	 $(call fbprint_b,"pktgen_dpdk") && \
	 $(call repo-mngr,fetch,pktgen_dpdk,apps/networking) && \
	 if [ ! -d $(RFSDIR)/usr/lib/aarch64-linux-gnu ]; then \
	     bld -i mkrfs -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
         if [ ! -d $(DESTDIR)/usr/local/dpdk ]; then \
	     bld -c dpdk -r $(DISTROTYPE):$(DISTROSCALE) -f $(CFGLISTYML); \
         fi && \
	 cd $(NETDIR)/pktgen_dpdk && \
	 export CROSS=$(CROSS_COMPILE) && \
	 export RTE_SDK=$(NETDIR)/dpdk && \
	 export RTE_TARGET=arm64-dpaa-linuxapp-gcc && \
	 export PKG_CONFIG_PATH=$(DESTDIR)/usr/local/lib/pkgconfig && \
	 sed -i "/^add_project_arguments('-march=native'/s/^/#&/" meson.build && \
	 sed -i -e "s#prefix=/usr/local#prefix=$(DESTDIR)/usr/local#g" $(DESTDIR)/usr/local/lib/pkgconfig/libdpdk*.pc && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@TARGET_ARCH@%aarch64%g' \
             -e 's%@TARGET_CPU@%cortex-a72%g' -e 's%@TARGET_ENDIAN@%little%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
             $(FBDIR)/src/misc/meson/cross-compilation.conf > $(NETDIR)/pktgen_dpdk/cross-compilation.conf && \
	 PKG_CONFIG_SYSROOT_DIR=$(RFSDIR) \
	 build_dir=build_arm64_$(DISTROTYPE)_$(DISTROSCALE) && \
	 meson $$build_dir -Dc_args="-DRTE_FORCE_INTRINSICS -I$(DESTDIR)/usr/local/include" \
			   -Dc_link_args="-L$(DESTDIR)/usr/local/lib -L$(RFSDIR)/lib/aarch64-linux-gnu" \
	                   --prefix=$(DESTDIR)/usr/local --buildtype=release --cross-file cross-compilation.conf && \
	 DESTDIR=$(DESTDIR) ninja -j $(JOBS) -C $$build_dir && \
	 install -m 755 $$build_dir/app/pktgen Pktgen.lua ${DESTDIR}/usr/local/bin && \
	 sed -i -e "s#prefix=$(DESTDIR)/usr/local#prefix=/usr/local#g" $(DESTDIR)/usr/local/lib/pkgconfig/libdpdk*.pc && \
	 $(call fbprint_d,"pktgen_dpdk")
endif
endif

# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



pktgen_dpdk:
	@[ $(DESTARCH) != arm64 -o $(DISTROVARIANT) = desktop -o \
	   $(DISTROVARIANT) = base -o $(DISTROVARIANT) = tiny ] && exit || \
	 $(call fbprint_b,"pktgen_dpdk") && \
	 $(call repo-mngr,fetch,pktgen_dpdk,apps/networking) && \
	 if [ ! -d $(RFSDIR)/usr/lib ]; then \
	     bld rfs -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -d $(DESTDIR)/usr/local/dpdk ]; then \
	     bld dpdk -r $(DISTROTYPE):$(DISTROVARIANT) -f $(CFGLISTYML); \
	 fi && \
	 \
	 cd $(NETDIR)/pktgen_dpdk && \
	 export RTE_SDK=$(NETDIR)/dpdk && \
	 export RTE_TARGET=arm64-dpaa-linuxapp-gcc && \
	 export RTE_TARGET=arm64-dpaa-linuxapp-gcc && export RTE_SDK=$(DESTDIR)/usr/share/dpdk && \
	 sed -i "/add_project_arguments('-march=native'/s/^/#&/" meson.build && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     -e 's%@DESTDIR@%$(DESTDIR)%g' $(FBDIR)/src/misc/meson/meson.cross > meson.cross && \
	 build_dir=build_$(DISTROTYPE)_$(ARCH) && \
	 \
	 meson setup $$build_dir \
		-Dc_args="-DRTE_FORCE_INTRINSICS -I$(DESTDIR)/usr/include -Wno-error=mismatched-dealloc \
			  -Wno-error=nonnull -Wno-error=implicit-function-declaration -Wno-error=unused-variable" \
		-Dc_link_args="-L$(DESTDIR)/usr/lib -L$(RFSDIR)/lib/aarch64-linux-gnu" \
		--prefix=$(DESTDIR)/usr --buildtype=release \
		--cross-file meson.cross && \
	 DESTDIR=$(DESTDIR) ninja -j $(JOBS) -C $$build_dir && \
	 install -m 755 $$build_dir/app/pktgen Pktgen.lua ${DESTDIR}/usr/bin && \
	 $(call fbprint_d,"pktgen_dpdk")

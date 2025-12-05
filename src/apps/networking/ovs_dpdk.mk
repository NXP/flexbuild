# Copyright 2017-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


ovs_dpdk: dpdk
	@[ $(SOCFAMILY) != LS -o $(DISTROVARIANT) != server ] && exit || \
	 $(call download_repo,ovs_dpdk,apps/networking) && \
	 $(call patch_apply,ovs_dpdk,apps/networking) && \
	 if [ ! -d $(RFSDIR)/usr/lib/aarch64-linux-gnu ]; then \
	     bld rfs -m $(MACHINE); \
	 fi && \
	 if [ ! -f $(RFSDIR)/usr/include/rte_config.h ]; then \
		sudo cp -Pf $(DESTDIR)/usr/include/rte_*.h $(RFSDIR)/usr/include/ && \
		sudo cp -rf $(DESTDIR)/usr/include/generic $(RFSDIR)/usr/include/; \
	 fi && \
	 \
	 $(call fbprint_b,"ovs_dpdk") && \
	 cd $(NETDIR)/ovs_dpdk && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export LDFLAGS="-L$(DESTDIR)/usr/lib -L$(RFSDIR)/usr/lib -L$(RFSDIR)/lib/aarch64-linux-gnu" && \
	 export LIBS="$(shell PKG_CONFIG_PATH=$(DESTDIR)/usr/lib/pkgconfig $(CROSS)pkg-config --libs libdpdk)" && \
	 export ovs_cv_groff=no && \
	 ./boot.sh $(LOG_MUTE) && \
	 ./configure --prefix=/usr \
	   --host=aarch64-linux-gnu \
	   --with-dpdk=static \
	   --disable-ssl \
	   --disable-libcapng $(LOG_MUTE) && \
	 $(MAKE) -j$(JOBS) --no-print-directory CFLAGS='-g -Ofast' install $(LOG_MUTE) && \
	 $(CROSS_COMPILE)strip $(DESTDIR)/usr/sbin/{ovs-vswitchd,ovsdb-server} && \
	 $(call fbprint_d,"ovs_dpdk")

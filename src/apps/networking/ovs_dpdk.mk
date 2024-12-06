# Copyright 2017-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


ovs_dpdk:
	@[ $(SOCFAMILY) != LS -o $(DISTROVARIANT) != server ] && exit || \
	 $(call fbprint_b,"ovs_dpdk") && \
	 $(call repo-mngr,fetch,ovs_dpdk,apps/networking) && \
	 if [ ! -d $(RFSDIR)/usr/lib/aarch64-linux-gnu ]; then \
	     bld rfs -r $(DISTROTYPE):$(DISTROVARIANT); \
	 fi && \
	 if [ ! -d $(DESTDIR)/usr/local/dpdk ]; then \
	     bld dpdk -r $(DISTROTYPE):$(DISTROVARIANT) -p $(SOCFAMILY); \
	 fi && \
         if [ ! -f $(RFSDIR)/usr/include/rte_config.h ]; then \
	     sudo cp -Pf $(DESTDIR)/usr/include/rte_*.h $(RFSDIR)/usr/include/ && \
             sudo cp -rf $(DESTDIR)/usr/include/generic $(RFSDIR)/usr/include/; \
         fi && \
	 \
	 cd $(NETDIR)/ovs_dpdk && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export LDFLAGS="-L$(DESTDIR)/usr/lib -L$(RFSDIR)/usr/lib -L$(RFSDIR)/lib/aarch64-linux-gnu" && \
	 export LIBS="$(shell PKG_CONFIG_PATH=$(DESTDIR)/usr/lib/pkgconfig $(CROSS)pkg-config --libs libdpdk)" && \
	 ./boot.sh && \
	 ./configure --prefix=/usr \
	   --host=aarch64-linux-gnu \
	   --with-dpdk=static \
	   --disable-ssl \
	   --disable-libcapng && \
	 $(MAKE) -j$(JOBS) --no-print-directory CFLAGS='-g -Ofast' install && \
	 $(CROSS_COMPILE)strip $(DESTDIR)/usr/sbin/{ovs-vswitchd,ovsdb-server} && \
	 $(call fbprint_d,"ovs_dpdk")

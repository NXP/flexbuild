# Copyright 2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# mTCP is a highly scalable user-level TCP stack for multicore systems.

# depend on libgmp-dev numactl dpdk

mtcp_dpdk:
ifeq ($(CONFIG_MTCP),y)
	@[ $(DESTARCH) != arm64 -o $(DISTROVARIANT) = desktop -o \
	   $(DISTROVARIANT) = base -o $(DISTROVARIANT) = tiny ] && exit || \
	 $(call fbprint_b,"mtcp_dpdk") && \
	 $(call repo-mngr,fetch,mtcp_dpdk,apps/networking) && \
	 if [ ! -d $(RFSDIR)/usr/lib/aarch64-linux-gnu ]; then \
	     bld rfs -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -d $(DESTDIR)/usr/local/dpdk ]; then \
	     bld dpdk -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH) -p $(SOCFAMILY) -f $(CFGLISTYML); \
	 fi && \
	 sudo cp -f $(DESTDIR)/usr/include/rte_*.h $(RFSDIR)/usr/include && \
	 sudo cp -Pf $(DESTDIR)/usr/lib/librte_* $(RFSDIR)/usr/lib && \
	 \
	 cd $(NETDIR)/mtcp_dpdk && \
	 sed -i 's/GCC=@CC@/CC=@CC@ -g -O3 -Wall -Werror -fgnu89-inline/' util/Makefile.in && \
	 \
	 ./configure CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" \
		     --host=aarch64-linux-gnu \
	             --with-dpdk-lib=$(DESTDIR)/usr \
		     --disable-static && \
	 $(MAKE) -j$(JOBS) setup-dpdk && \
	 $(MAKE) -j$(JOBS) && \
	 $(MAKE) -j$(JOBS) -C apps/perf && \
	 install -d $(DESTDIR)/usr/local/bin/mtcp && \
	 cp -f apps/perf/{*.sh,*.py,client,client.conf,README.md}  $(DESTDIR)/usr/local/bin/mtcp && \
	 cp -f apps/example/{epserver,epwget} $(DESTDIR)/usr/local/bin/mtcp && \
	 $(call fbprint_d,"mtcp_dpdk")
endif

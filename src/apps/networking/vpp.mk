# Copyright 2017-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# open source version of Cisco's Vector Packet Processing (VPP)
# https://wiki.fd.io/view/VPP

# depends on libmnl-dev for libmnl/libmnl.h
# Need git information to compile, so must use git clone

#vpp:
vpp: dpdk
	@[ $(SOCFAMILY) != LS -o $(DISTROVARIANT) != server ] && exit || \
	 $(call download_repo,vpp,apps/networking,git) && \
	 $(call patch_apply,vpp,apps/networking) && \
	 if [ ! -d $(RFSDIR)/usr/lib/aarch64-linux-gnu ]; then \
	     bld rfs -m $(MACHINE); \
	 fi && \
	 $(call fbprint_b,"vpp") && \
	 export CROSS_PREFIX=aarch64-linux-gnu && \
	 export CROSS_TOOLCHAIN=/usr && \
	 export CROSS_SYSROOT=$(RFSDIR) && \
	 export ARCH=arm64 && export OPENSSL_PATH=$(RFSDIR)/usr && \
	 export EXTRA_INC="$(NETDIR)/dpdk/lib/eal/include -I$(NETDIR)/dpdk/drivers/bus/vmbus \
	 	-I$(NETDIR)/dpdk/lib/cryptodev -I$(RFSDIR)/usr/include/aarch64-linux-gnu" && \
	 export EXTRA_LIBS=$(RFSDIR)/lib/aarch64-linux-gnu && \
	 export DPDK_PATH=$(DESTDIR)/usr && \
	 export PYTHONPATH=$(RFSDIR)/usr/lib/python3.13:$(PYTHONPATH) && \
	 export LD_LIBRARY_PATH=$(DESTDIR)/usr/local/lib:$(RFSDIR)/lib/aarch64-linux-gnu:$(RFSDIR)/lib && \
	 if [ -f $(RFSDIR)/usr/include/mbedtls/ssl.h ]; then \
		mv $(RFSDIR)/usr/include/mbedtls/ssl.h $(RFSDIR)/usr/include/mbedtls/ssl.h.bak; \
	 fi && \
	 if [ -f $(DESTDIR)/usr/include/mbedtls/ssl.h ]; then \
		mv $(DESTDIR)/usr/include/mbedtls/ssl.h $(DESTDIR)/usr/include/mbedtls/ssl.h.bak; \
	 fi && \
	 cd $(NETDIR)/vpp && \
	 $(MAKE) -j$(JOBS) install-dep $(LOG_MUTE) && \
	 cd build-root && \
	 $(MAKE) -j$(JOBS) distclean $(LOG_MUTE) && \
	 $(MAKE) -j$(JOBS) V=0 PLATFORM=dpaa TAG=dpaa vpp-package-deb $(LOG_MUTE) && \
	 mkdir -p $(DESTDIR)/usr/local/vpp ${DESTDIR}/etc/vpp && \
	 cp -f *.deb $(DESTDIR)/usr/local/vpp && \
	 cp -f $(NETDIR)/vpp/src/vpp/conf/startup.conf $(DESTDIR)/etc/vpp/startup.conf && \
	 if [ -f $(DESTDIR)/usr/include/mbedtls/ssl.h.bak ]; then \
		mv $(DESTDIR)/usr/include/mbedtls/ssl.h.bak $(DESTDIR)/usr/include/mbedtls/ssl.h; \
	 fi && \
	 if [ -f $(RFSDIR)/usr/include/mbedtls/ssl.h.bak ]; then \
		mv $(RFSDIR)/usr/include/mbedtls/ssl.h.bak $(RFSDIR)/usr/include/mbedtls/ssl.h; \
	 fi && \
	 $(call fbprint_d,"vpp")

# Copyright 2017-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# open source version of Cisco's Vector Packet Processing (VPP)
# https://wiki.fd.io/view/VPP

# depends on libmnl-dev for libmnl/libmnl.h

vpp:
	@[ $(SOCFAMILY) != LS -o $(DISTROVARIANT) != server ] && exit || \
	 $(call fbprint_b,"vpp") && \
	 $(call repo-mngr,fetch,vpp,apps/networking) && \
	 if [ ! -d $(RFSDIR)/usr/lib/aarch64-linux-gnu ]; then \
	     bld rfs -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 if [ ! -d $(DESTDIR)/usr/local/dpdk ]; then \
	     bld dpdk -r $(DISTROTYPE):$(DISTROVARIANT); \
	 fi && \
	 export CROSS_PREFIX=aarch64-linux-gnu && \
	 export CROSS_TOOLCHAIN=/usr && \
	 export CROSS_SYSROOT=$(RFSDIR) && \
	 export ARCH=arm64 && export OPENSSL_PATH=$(RFSDIR)/usr && \
	 export EXTRA_INC="$(NETDIR)/dpdk/lib/eal/include -I$(NETDIR)/dpdk/drivers/bus/vmbus \
	 	-I$(NETDIR)/dpdk/lib/cryptodev -I$(RFSDIR)/usr/include/aarch64-linux-gnu" && \
	 export EXTRA_LIBS=$(RFSDIR)/lib/aarch64-linux-gnu && \
	 export DPDK_PATH=$(DESTDIR)/usr && \
	 export LD_LIBRARY_PATH=$(DESTDIR)/usr/local/lib:$(RFSDIR)/lib/aarch64-linux-gnu:$(RFSDIR)/lib && \
	 [ ! -f /usr/lib/python3.11/_sysconfigdata__aarch64-linux-gnu.py ] && \
	 sudo ln -s $(RFSDIR)/usr/lib/python3.11/_sysconfigdata__aarch64-linux-gnu.py \
	 /usr/lib/python3.11/_sysconfigdata__aarch64-linux-gnu.py || true && \
	 \
	 cd $(NETDIR)/vpp && \
	 sed -i -e 's/22.04)/12)/g' -e 's/clang-format-11/clang-format/g' \
		-e 's/libffi7/libffi8/g' -e 's/E apt-get/E apt-get -y/g' Makefile && \
	 sed -i -e "s/-Werror -Wall//g" -e "/^#check_c_compiler_flag/s/#//g" \
	        -e "/^#		      compiler_flag_no_address/s/#//g" src/CMakeLists.txt && \
	 $(MAKE) -j$(JOBS) install-dep && \
	 cd build-root && \
	 $(MAKE) -j$(JOBS) distclean && \
	 $(MAKE) -j$(JOBS) V=0 PLATFORM=dpaa TAG=dpaa vpp-package-deb && \
	 mkdir -p $(DESTDIR)/usr/local/vpp ${DESTDIR}/etc/vpp && \
	 cp -vf *.deb $(DESTDIR)/usr/local/vpp && \
	 cp -f $(NETDIR)/vpp/src/vpp/conf/startup.conf $(DESTDIR)/etc/vpp/startup.conf && \
	 $(call fbprint_d,"vpp")

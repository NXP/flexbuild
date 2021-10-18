# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# cross build VPP


vpp:
ifneq ($(CONFIG_VPP)$(FORCE), "n")
ifeq ($(DESTARCH),arm64)
	@[ $(SOCFAMILY) != LS -a $(DISTROTYPE) != ubuntu -a $(DISTROTYPE) != yocto -o \
	   $(DISTROSCALE) = desktop -o $(DISTROSCALE) = lite -o $(DISTROSCALE) = tiny ] && exit || \
	 $(call fbprint_b,"vpp") && \
	 $(call repo-mngr,fetch,vpp,apps/networking) && \
	 if [ ! -d $(RFSDIR)/usr/lib/aarch64-linux-gnu ]; then \
	     bld -i mkrfs -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -d $(DESTDIR)/usr/local/dpdk ]; then \
	     bld -c dpdk -r $(DISTROTYPE):$(DISTROSCALE) -f $(CFGLISTYML); \
	 fi && \
	 export CROSS_PREFIX=aarch64-linux-gnu && \
	 export CROSS_TOOLCHAIN=/usr && \
	 export CROSS_SYSROOT=$(RFSDIR) && \
	 export ARCH=arm64 && export OPENSSL_PATH=$(RFSDIR)/usr && \
	 export EXTRA_INC=$(RFSDIR)/usr/include/aarch64-linux-gnu && \
	 export EXTRA_LIBS=$(RFSDIR)/lib/aarch64-linux-gnu && \
	 export DPDK_PATH=$(DESTDIR)/usr/local && \
	 export FORCE="-y" && \
	 export LD_LIBRARY_PATH=$(DESTDIR)/usr/local/lib:$(RFSDIR)/lib/aarch64-linux-gnu:$(RFSDIR)/lib && \
	 if [ ! -f /usr/lib/python3.8/_sysconfigdata_m_linux_aarch64-linux-gnu.py ]; then \
	     sudo ln -s _sysconfigdata__x86_64-linux-gnu.py /usr/lib/python3.8/_sysconfigdata_m_linux_aarch64-linux-gnu.py; \
	 fi && \
	 if [ -f $(RFSDIR)/usr/bin/ninja ]; then sudo mv $(RFSDIR)/usr/bin/ninja $(RFSDIR)/usr/bin/.ninja; fi && \
	 cd $(NETDIR)/vpp && \
	 sed -i -e "s/-Werror -Wall//g" -e "/^#check_c_compiler_flag/s/#//g" \
	        -e "/^#		      compiler_flag_no_address/s/#//g" src/CMakeLists.txt && \
	 $(MAKE) -j$(JOBS) install-dep && \
	 cd build-root && \
	 $(MAKE) -j$(JOBS) distclean && \
	 $(MAKE) -j$(JOBS) V=0 PLATFORM=dpaa TAG=dpaa vpp-package-deb && \
	 mkdir -p $(DESTDIR)/usr/local/vpp && \
	 cp -vf *.deb $(DESTDIR)/usr/local/vpp && \
	 if [ -f $(RFSDIR)/usr/bin/.ninja ]; then sudo mv $(RFSDIR)/usr/bin/.ninja $(RFSDIR)/usr/bin/ninja; fi && \
	 $(call fbprint_d,"vpp")
endif
else
	@if [ $(SOCFAMILY) = LS ]; then $(call fbprint_w,INFO: VPP is not enabled by default in configs/$(CFGLISTYML)); fi
endif

# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



fmlib:
ifeq ($(DESTARCH),arm64)
	@[ $(SOCFAMILY) != LS -a $(DISTROTYPE) = centos -o \
	   $(DISTROSCALE) = desktop -o $(DISTROSCALE) = tiny ] && exit || \
	 $(call fbprint_b,"fmlib") && \
	 $(call repo-mngr,fetch,fmlib,apps/networking) && \
	 if [ ! -d $(KERNEL_PATH)/include/uapi/linux/fmd ]; then \
	     bld -c linux -p LS -f $(CFGLISTYML); \
	 fi && \
	 cd $(NETDIR)/fmlib && \
	 export KERNEL_SRC=$(KERNEL_PATH) && \
	 $(MAKE) clean && $(MAKE) && \
	 $(MAKE) install-libfm-arm && \
	 $(call fbprint_d,"fmlib")
endif

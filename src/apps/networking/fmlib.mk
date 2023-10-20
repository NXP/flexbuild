# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# DPAA1 Frame Manager User Space Library

fmlib:
	@[ $(SOCFAMILY) != LS -o $(DISTROVARIANT) = tiny -o $(DISTROVARIANT) = base ] && exit || \
	 $(call fbprint_b,"fmlib") && \
	 $(call repo-mngr,fetch,fmlib,apps/networking) && \
	 if [ ! -d $(KERNEL_PATH)/include/uapi/linux/fmd ]; then \
	     bld linux -a $(DESTARCH) -p $(SOCFAMILY) -f $(CFGLISTYML); \
	 fi && \
	 cd $(NETDIR)/fmlib && \
	 export PREFIX=/usr && \
	 export KERNEL_SRC=$(KERNEL_PATH) && \
	 export CFLAGS="-O2 -pipe -I$(RFSDIR)/usr/include -I$(RFSDIR)/usr/include/aarch64-linux-gnu" && \
	 $(MAKE) clean && \
	 $(MAKE) && \
	 $(MAKE) install-libfm-arm && \
	 $(call fbprint_d,"fmlib")

# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# DPAA1 Frame Manager User Space Library

fmlib:
	@[ $(SOCFAMILY) != LS -o $(DISTROVARIANT) != server ] && exit || \
	 $(call repo-mngr,fetch,fmlib,apps/networking) && \
	 if [ ! -d $(KERNEL_PATH)/include/uapi/linux/fmd ]; then \
	     bld linux -a $(DESTARCH) -p $(SOCFAMILY); \
	 fi && \
	 $(call fbprint_b,"fmlib") && \
	 cd $(NETDIR)/fmlib && \
	 export PREFIX=/usr && \
	 export KERNEL_SRC=$(KERNEL_PATH) && \
	 export CFLAGS="-O2 -pipe -I$(RFSDIR)/usr/include -I$(RFSDIR)/usr/include/aarch64-linux-gnu" && \
	 $(MAKE) clean $(LOG_MUTE) && \
	 $(MAKE) -j$(JOBS) $(LOG_MUTE) && \
	 $(MAKE) install-libfm-arm $(LOG_MUTE) && \
	 $(call fbprint_d,"fmlib")

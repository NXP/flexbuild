# Copyright 2017-2023,2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# DPAA1 Frame Manager User Space Library

fmlib:
	@[ $(SOCFAMILY) != LS -o $(DISTROVARIANT) != server ] && exit || \
	 $(call download_repo,fmlib,apps/networking) && \
	 $(call patch_apply,fmlib,apps/networking) && \
	 $(call fbprint_b,"fmlib") && \
	 cd $(NETDIR)/fmlib && \
	 export PREFIX=/usr && \
	 export KERNEL_SRC=$(KERNEL_PATH) && \
	 export CFLAGS="-O2 -pipe -I$(RFSDIR)/usr/include -I$(RFSDIR)/usr/include/aarch64-linux-gnu" && \
	 $(MAKE) clean $(LOG_MUTE) && \
	 $(MAKE) $(LOG_MUTE) && \
	 $(MAKE) install-libfm-arm $(LOG_MUTE) && \
	 $(call fbprint_d,"fmlib")

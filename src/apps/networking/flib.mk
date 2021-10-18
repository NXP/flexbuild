# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


flib:
ifeq ($(DESTARCH),arm64)
	@[ $(SOCFAMILY) != LS -a $(DISTROTYPE) = centos -o \
	   $(DISTROSCALE) = desktop -o $(DISTROSCALE) = tiny ] && exit || \
	 $(call fbprint_b,"flib") && \
	 $(call repo-mngr,fetch,flib,apps/networking) && \
	 $(MAKE) -C $(NETDIR)/flib install && \
	 $(call fbprint_d,"flib")
endif

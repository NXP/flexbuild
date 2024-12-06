# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


flib:
	@[ $(SOCFAMILY) != LS -o $(DISTROVARIANT) != server ] && exit || \
	 $(call fbprint_b,"flib") && \
	 $(call repo-mngr,fetch,flib,apps/networking) && \
	 $(MAKE) -C $(NETDIR)/flib install && \
	 $(call fbprint_d,"flib")

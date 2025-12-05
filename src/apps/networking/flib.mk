# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


flib:
	@[ $(SOCFAMILY) != LS -o $(DISTROVARIANT) != server ] && exit || \
	 $(call download_repo,flib,apps/networking) && \
	 $(call patch_apply,flib,apps/networking) && \
	 $(call fbprint_b,"flib") && \
	 $(MAKE) -C $(NETDIR)/flib install $(LOG_MUTE) && \
	 $(call fbprint_d,"flib")

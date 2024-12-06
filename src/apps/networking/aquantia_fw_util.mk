# Copyright 2021-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# a utility to program Aquantia PHY firmware

aquantia_fw_util:
	@[ $(SOCFAMILY) != LS -o $(DISTROVARIANT) != server ] && exit || \
	 $(call repo-mngr,fetch,aquantia_fw_util,apps/networking) && \
	 cd $(NETDIR)/aquantia_fw_util && \
	 $(MAKE) -j$(JOBS) && \
	 cp -f aq-firmware-tool $(DESTDIR)/usr/local/bin && \
	 $(call fbprint_d,"aquantia_fw_util")

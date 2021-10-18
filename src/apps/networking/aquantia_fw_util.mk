# Copyright 2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# a utility to program Aquantia PHY firmware

aquantia_fw_util:
ifeq ($(DESTARCH),arm64)
	@[ $(SOCFAMILY) != LS -o $(DISTROTYPE) != ubuntu -o $(DISTROTYPE) != yocto ] && exit || \
	 $(call repo-mngr,fetch,aquantia_fw_util,apps/networking) && \
	 cd $(NETDIR)/aquantia_fw_util && \
	 $(MAKE) -j$(JOBS) && \
	 cp -f aq-firmware-tool $(DESTDIR)/usr/local/bin && \
	 $(call fbprint_d,"aquantia_fw_util")
endif

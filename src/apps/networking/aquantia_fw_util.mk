# Copyright 2021-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# a utility to program Aquantia PHY firmware

aquantia_fw_util:
	@[ $(SOCFAMILY) != LS -o $(DISTROVARIANT) != server ] && exit || \
	 $(call download_repo,aquantia_fw_util,apps/networking) && \
	 $(call patch_apply,aquantia_fw_util,apps/networking) && \
	 $(call fbprint_b,"aquantia_fw_util") && \
	 cd $(NETDIR)/aquantia_fw_util && \
	 $(MAKE) -j$(JOBS) $(LOG_MUTE) && \
	 cp -f aq-firmware-tool $(DESTDIR)/usr/local/bin && \
	 $(call fbprint_d,"aquantia_fw_util")

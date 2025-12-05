# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# DPAA2 Resource Manager Tool

restool:
	@[ $(SOCFAMILY) != LS -o $(DISTROVARIANT) != server ] && exit || \
	 $(call download_repo,restool,apps/networking) && \
	 $(call patch_apply,restool,apps/networking) && \
	 $(call fbprint_b,"restool") && \
	 cd $(NETDIR)/restool && \
	 $(MAKE) clean && \
	 $(MAKE) -j$(JOBS) $(LOG_MUTE) && \
	 $(MAKE) -j$(JOBS) install $(LOG_MUTE) && \
	 $(call fbprint_d,"restool")

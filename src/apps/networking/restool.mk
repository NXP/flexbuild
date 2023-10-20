# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# DPAA2 Resource Manager Tool

restool:
	@[ $(DESTARCH) != arm64 -o $(SOCFAMILY) != LS ] && exit || \
	 $(call repo-mngr,fetch,restool,apps/networking) && \
	 cd $(NETDIR)/restool && \
	 $(MAKE) clean && \
	 $(MAKE) -j$(JOBS) && \
	 $(MAKE) -j$(JOBS) install && \
	 $(call fbprint_d,"restool")

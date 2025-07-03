#
# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
#
# SDK linux kernel and modules components

SHELL=/bin/bash
include $(FBDIR)/configs/$(CONFIGLIST)
#include $(FBDIR)/include/repo.mk
include $(FBDIR)/include/utils.mk
include $(FBDIR)/include/download_repo.mk
include $(FBDIR)/include/patch_apply.mk
include $(FBDIR)/configs/.repo_pool

include linux.mk
include perf.mk
include cryptodev_linux.mk
include lttng_modules.mk
include mdio_proxy_module.mk
include isp_vvcam_module.mk
include nxp_wlan_bt.mk

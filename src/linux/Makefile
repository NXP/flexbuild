#
# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
#
# SDK linux kernel and modules components

SHELL=/bin/bash
include $(FBDIR)/configs/$(CONFIGLIST)
include $(FBDIR)/include/repo.mk
include $(FBDIR)/include/repo_update.inc
include $(FBDIR)/src/apps/connectivity/nxp_wlan_bt.mk

include linux.mk
include perf.mk
include cryptodev_linux.mk
include lttng_modules.mk
include mdio_proxy_module.mk
include isp_vvcam_module.mk


linux-modules: cryptodev_linux mdio_proxy_module isp_vvcam_module nxp_wlan_bt

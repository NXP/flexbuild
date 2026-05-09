#
# Copyright 2017-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
#
# SDK linux kernel and modules components


DTBSTR := $(if $(filter y,$(CONFIG_PLATFORM_IMX)),imx*.dtb,fsl*.dtb)

LINUX_MODULES := \
    cryptodev_linux \
    isp_vvcam_module \
    nxp_wlan_bt \
    mdio_proxy_module

# ============================================================================
# Conditionally include enabled modules based on Kconfig
# ============================================================================
LINUX_MODULES-y :=

# Add modules based on CONFIG_* settings
LINUX_MODULES-$(CONFIG_CRYPTODEV_LINUX)   += cryptodev_linux
LINUX_MODULES-$(CONFIG_ISP_VVCAM_MODULE)  += isp_vvcam_module
LINUX_MODULES-$(CONFIG_NXP_WLAN_BT)       += nxp_wlan_bt
LINUX_MODULES-$(CONFIG_MDIO_PROXY_MODULE) += mdio_proxy_module

$(foreach m,$(LINUX_MODULES-y), \
    $(eval include $(FBDIR)/src/linux/$(m).mk))

include $(FBDIR)/src/linux/linux.mk

.PHONY: linux-modules
linux-modules: $(LINUX_MODULES-y)
	@$(call fbprint_d,"linux-modules")

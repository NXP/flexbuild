#
# Copyright 2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
# SDK Application Components
#



# ============================================================================
# Define all possible networking modules
# ============================================================================
NET_MODULES := \
    aiopsl \
    aquantia_fw_util \
    ceetm \
    dce \
    dpdk \
    flib \
    fmc \
    fmlib \
    gpp_aioptool \
    ovs_dpdk \
    pktgen_dpdk \
    qbman_userspace \
    restool \
    spc \
    tsntool \
    vpp

# ============================================================================
# Conditionally include enabled modules based on Kconfig
# ============================================================================
APPS_NET-y :=

# Add modules based on CONFIG_NET_* settings
APPS_NET-$(CONFIG_NET_AIOPSL) += aiopsl
APPS_NET-$(CONFIG_NET_AQUANTIA_FW_UTIL) += aquantia_fw_util
APPS_NET-$(CONFIG_NET_CEETM) += ceetm
APPS_NET-$(CONFIG_NET_DCE) += dce
APPS_NET-$(CONFIG_NET_DPDK) += dpdk
APPS_NET-$(CONFIG_NET_FLIB) += flib
APPS_NET-$(CONFIG_NET_FMC) += fmc
APPS_NET-$(CONFIG_NET_FMLIB) += fmlib
APPS_NET-$(CONFIG_NET_GPP_AIOPTOOL) += gpp_aioptool
APPS_NET-$(CONFIG_NET_OVS_DPDK) += ovs_dpdk
APPS_NET-$(CONFIG_NET_PKTGEN_DPDK) += pktgen_dpdk
APPS_NET-$(CONFIG_NET_QBMAN_USERSPACE) += qbman_userspace
APPS_NET-$(CONFIG_NET_RESTOOL) += restool
APPS_NET-$(CONFIG_NET_SPC) += spc
APPS_NET-$(CONFIG_NET_TSNTOOL) += tsntool
APPS_NET-$(CONFIG_NET_VPP) += vpp

# Create alias for backward compatibility
APPS_NET := $(APPS_NET-y)

# ============================================================================
# Include makefiles for enabled modules
# ============================================================================
$(foreach m,$(APPS_NET-y), \
    $(eval include $(FBDIR)/src/apps/networking/$(m).mk))

# ============================================================================
# Networking target using APPS_NET-y
# ============================================================================
.PHONY: networking
networking: $(APPS_NET-y)

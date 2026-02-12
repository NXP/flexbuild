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
# Automatically include enabled modules and build APPS_NET
# ============================================================================
APPS_NET :=

$(foreach m,$(NET_MODULES), \
    $(eval _cfg := CONFIG_NET_$(shell echo $(m) | tr a-z A-Z)) \
    $(if $(filter y,$($(_cfg))), \
        $(eval include $(FBDIR)/src/apps/networking/$(m).mk)) \
    $(if $(filter y,$($(_cfg))), \
        $(eval APPS_NET += $(m))) \
)

# ============================================================================
# Networking target using APPS_NET
# ============================================================================
.PHONY: networking
networking: $(APPS_NET)


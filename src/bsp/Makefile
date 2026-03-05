#
# Copyright 2017-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
# SDK BSP Components

BSPDIR := $(PKGDIR)/bsp

BSP_MAP-y                          := atf.mk uboot.mk
BSP_MAP-$(CONFIG_PLATFORM_IMX)     += imx_mkimage.mk
BSP_MAP-$(CONFIG_PLATFORM_LS)      += layerscape_fw.mk rcw.mk
BSP_MAP-$(CONFIG_SOC_IMX95)        += imx_oei.mk imx_sm.mk

BSP_MK_FILES := $(sort $(BSP_MAP-y))
include $(addprefix src/bsp/,$(BSP_MK_FILES))


#
# Copyright 2017-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
# SDK BSP Components

BSPDIR := $(PKGDIR)/bsp

BSP_MK_FILES := $(wildcard $(FBDIR)/src/bsp/*.mk)
BSP_TARGETS := $(basename $(notdir $(BSP_MK_FILES)))
include $(BSP_MK_FILES)


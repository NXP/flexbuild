#
# Copyright 2017-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
#
# SDK linux kernel and modules components


KOUTDIR := $(KERNEL_OUTPUT_PATH)/$(KERNEL_BRANCH)
KTGT_DIR := $(FBOUTDIR)/linux/$(KERNEL_TREE)/arm64/$(SOCFAMILY)
DTBSTR := $(if $(filter y,$(CONFIG_PLATFORM_IMX)),imx*.dtb,fsl*.dtb)
KERNEL_IMAGE := $(KTGT_DIR)/Image
KHEADER_FILE := $(DESTDIR)/usr/include/linux/version.h

# Find and include all .mk files in this directory
LINUX_MAP-y                           := linux.mk
LINUX_MAP-$(CONFIG_CRYPTODEV_LINUX)   += cryptodev_linux.mk
LINUX_MAP-$(CONFIG_ISP_VVCAM_MODULE)  += isp_vvcam_module.mk
LINUX_MAP-$(CONFIG_NXP_WLAN_BT)       += nxp_wlan_bt.mk
LINUX_MAP-$(CONFIG_MDIO_PROXY_MODULE) += mdio_proxy_module.mk

LINUX_MK_FILES := $(sort $(LINUX_MAP-y))
include $(addprefix src/linux/,$(LINUX_MK_FILES))

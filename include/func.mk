#
# Copyright 2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
# Author: Andy Tang <andy.tang@nxp.com>
#
#

.PHONY: bsp fw distroscr rfs packrfs packapp packapps itb mklinux boot merge-apps host-dep docker


BSP_DEPS := $(KERNEL_IMAGE) itb distroscr
BSP_DEPS += $(if $(filter y,$(CONFIG_PLATFORM_LS)),atf layerscape_fw,flash.bin)
fw bsp: $(BSP_DEPS)
	@/bin/bash -e $(FBDIR)/tools/create_composite_firmware

distroscr:
	@$(BLD) distroscr

packrfs:
	@$(BLD) packrfs

packapp packapps:
	@$(BLD) packapps

itb mklinux: $(KERNEL_IMAGE)
	@$(BLD) itb

boot: $(KERNEL_IMAGE) linux-modules distroscr
	@/bin/bash -e $(FBDIR)/tools/create_bootpartition

merge-apps:
	@$(BLD) merge-apps

host-dep:
	@$(BLD) host-dep

docker:
	+@$(BLD) docker


rfs: $(KHEADER_FILE)
	@/bin/bash -e $(FBDIR)/tools/distro_debian

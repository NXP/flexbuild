#
# Copyright 2017-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
# Author: Andy Tang <andy.tang@nxp.com>
#
#

.PHONY: bsp fw distroscr fwall bspall distroscrall rfs packrfs packapp packapps itb mklinux boot merge-apps host-dep docker


BSP_DEPS := $(KERNEL_IMAGE) itb distroscr
BSP_DEPS += $(if $(filter y,$(CONFIG_PLATFORM_LS)),atf layerscape_fw,flash.bin)
fw bsp: $(BSP_DEPS)
	@/bin/bash -e $(FBDIR)/tools/create_composite_firmware

distroscr:
	@$(BLD) distroscr -m $(MACHINE)

packrfs:
	@$(BLD) packrfs -m $(MACHINE)

packapp packapps:
	@$(BLD) packapps -m $(MACHINE)

itb mklinux: $(KERNEL_IMAGE)
	@$(BLD) itb -m $(MACHINE)

boot:
	@$(BLD) boot -m $(MACHINE)

merge-apps:
	@$(BLD) merge-apps -m $(MACHINE)

host-dep:
	@$(BLD) host-dep

docker:
	@$(BLD) docker


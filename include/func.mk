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

boot: $(KERNEL_IMAGE) distroscr
	@/bin/bash -e $(FBDIR)/tools/create_bootpartition

merge-apps:
	@$(BLD) merge-apps

host-dep:
	@$(BLD) host-dep

docker:
	+@if [ -f /.dockerenv ] || grep -q docker /proc/1/cgroup 2>/dev/null; then \
		echo "ERROR: Already inside a Docker container!" >&2; \
		echo ""; \
		exit 1; \
	fi
	@$(BLD) docker || true

rfs $(RFS_FILE):
	@/bin/bash -e $(FBDIR)/tools/distro_debian

wic:
	@$(BLD) wic

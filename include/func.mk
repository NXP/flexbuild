#
# Copyright 2017-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
# Author: Andy Tang <andy.tang@nxp.com>
#
#

.PHONY: bsp fw distroscr fwall bspall distroscrall rfs packrfs packapp packapps itb mklinux boot merge-apps host-dep docker



linux_itb=$(FBOUTDIR)/images/$(DISTRIB_VERSION)_poky_tiny_${SOCFAMILY}_arm64.itb
LINUX_IMAGE=$(FBOUTDIR)/linux/linux/arm64/$(SOCFAMILY)/Image.gz
LINUX_TS=$(FBDIR)/logs/.linux_timestamp_$(SOCFAMILY)

$(LINUX_TS):
	@echo "Building Linux for $(SOCFAMILY)..."
	$(MAKE) linux
	@touch $(LINUX_TS)

$(LINUX_IMAGE): $(LINUX_TS)
	@echo "Verifying Linux image..."
	@if [ ! -f "$(LINUX_IMAGE)" ]; then \
		echo "Error: Linux image not generated: $(LINUX_IMAGE)"; \
		echo "Expected path: $(FBOUTDIR)/linux/linux/arm64/$(SOCFAMILY)/Image.gz"; \
		exit 1; \
	fi

fw bsp:
	@$(BLD) bsp -m $(MACHINE)

fwall bspall:
	@for brd in $(MACHINE_LIST); do \
		$(BLD) bsp -m $$brd; \
	done

distroscr:
	@$(BLD) distroscr -m $(MACHINE)

distroscrall:
	@for brd in $(MACHINE_LIST); do \
		$(BLD) distroscr -m $$brd; \
	done

packrfs:
	@$(BLD) packrfs -m $(MACHINE)

packapp packapps:
	@$(BLD) packapps -m $(MACHINE)

itb mklinux:
	@$(BLD) itb -m $(MACHINE)

boot:
	@$(BLD) boot -m $(MACHINE)

merge-apps:
	@$(BLD) merge-apps -m $(MACHINE)

host-dep:
	@if ! [ -f /.dockerenv ] && ! grep -q docker /proc/1/cgroup 2>/dev/null; then \
		echo "ERROR: must be run inside a Docker container!" >&2; \
		echo "       Please run "make docker" first"; \
		exit 1; \
	fi
	$(BLD) host-dep; \


docker:
	@$(BLD) docker


#
# Copyright 2017-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
# Author: Andy Tang <andy.tang@nxp.com>
#
#

.PHONY: bsp fw distroscr fwall bspall distroscrall rfs packrfs packapp packapps itb mklinux boot merge-apps host-dep docker



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
	@$(BLD) host-dep


docker:
	@$(BLD) docker


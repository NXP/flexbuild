#
# Copyright 2017-2023,2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# RCW for NXP QorIQ Layerscape SoC.

RCW_MACHINE := $(if $(filter y,$(CONFIG_SOC_LX2160ARDB)),$(MACHINE)_rev2,$(MACHINE))
RCW_INST_DIR   := $(FBOUTDIR)/bsp/rcw

.PHONY: rcw
rcw:
	@$(call download_repo,rcw,bsp)
	$(call fbprint_b,"RCW for $(MACHINE)")
	mkdir -p $(RCW_INST_DIR)
	$(MAKE) -C $(BSPDIR)/rcw/$(RCW_MACHINE) $(LOG_MUTE)
	$(MAKE) -C $(BSPDIR)/rcw/$(RCW_MACHINE) install DESTDIR=$(RCW_INST_DIR)/$(MACHINE) $(LOG_MUTE)
	rm -f $(RCW_INST_DIR)/*/README
	$(call fbprint_d,"RCW")

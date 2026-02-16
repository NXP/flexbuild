#
# Copyright 2017-2023,2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# RCW for NXP QorIQ Layerscape SoC.

.PHONY: rcw
rcw:
	@$(call download_repo,rcw,bsp) && \
    $(call fbprint_b,"RCW for $(MACHINE)") && \
	cd $(BSPDIR) && mkdir -p $(FBOUTDIR)/bsp/rcw && \
	if [ $${MACHINE:0:6} = lx2160 ]; then \
		machine=$${MACHINE:0:10}_rev2; \
	else \
		machine=$(MACHINE); \
	fi && \
	$(MAKE) -C rcw/$$machine $(LOG_MUTE) && \
	$(MAKE) -C rcw/$$machine install DESTDIR=$(FBOUTDIR)/bsp/rcw/$(MACHINE) $(LOG_MUTE) && \
	rm -f $(FBOUTDIR)/bsp/rcw/*/README && \
	$(call fbprint_d,"RCW")

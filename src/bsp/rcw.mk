#
# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# RCW for NXP QorIQ Layerscape SoC.

rcw:
	@[ $(SOCFAMILY) != LS ] && exit || \
	 $(call download_repo,rcw,bsp) && \
     $(call fbprint_b,"RCW for $(MACHINE)") && \
	 cd $(BSPDIR) && mkdir -p $(FBOUTDIR)/bsp/rcw
ifeq ($(MACHINE), all)
	@cd $(BSPDIR) && \
	 for brd in `find rcw -maxdepth 1 -type d -name "l*"|cut -d/ -f2`; do \
	     test -f rcw/$$brd/Makefile || continue; \
	     $(MAKE) -C rcw/$$brd $(LOG_MUTE) && \
	     $(MAKE) -C rcw/$$brd install DESTDIR=$(FBOUTDIR)/bsp/rcw/$$brd $(LOG_MUTE) ; \
	 done
else
	@cd $(BSPDIR) && \
	 [ $${MACHINE:0:6} = lx2160 ] && machine=$${MACHINE:0:10}_rev2 || machine=$(MACHINE) && \
	 $(MAKE) -C rcw/$$machine $(LOG_MUTE) && \
	 $(MAKE) -C rcw/$$machine install DESTDIR=$(FBOUTDIR)/bsp/rcw/$(MACHINE) $(LOG_MUTE)
endif
	@rm -f $(FBOUTDIR)/bsp/rcw/*/README && \
	$(call fbprint_d,"RCW")

#
# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# RCW for NXP QorIQ Layerscape SoC.

rcw:
	@[ $(SOCFAMILY) != LS ] && exit || \
	 $(call repo-mngr,fetch,rcw,bsp) && \
	 cd $(BSPDIR) && mkdir -p $(FBOUTDIR)/bsp/rcw
ifeq ($(MACHINE), all)
	@cd $(BSPDIR) && \
	 for brd in `find rcw -maxdepth 1 -type d -name "l*"|cut -d/ -f2`; do \
	     test -f rcw/$$brd/Makefile || continue; \
	     $(MAKE) -C rcw/$$brd && \
	     $(MAKE) -C rcw/$$brd install DESTDIR=$(FBOUTDIR)/bsp/rcw/$$brd; \
	 done
else
	@cd $(BSPDIR) && \
	 [ $${MACHINE:0:5} = lx216 ] && machine=$${MACHINE:0:10}_rev2 || machine=$(MACHINE) && \
	 $(MAKE) -C rcw/$$machine && \
	 $(MAKE) -C rcw/$$machine install DESTDIR=$(FBOUTDIR)/bsp/rcw/$(MACHINE)
endif
	@rm -f $(FBOUTDIR)/bsp/rcw/*/README && \
	$(call fbprint_d,"RCW")

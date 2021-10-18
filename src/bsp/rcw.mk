#
# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



rcw:
ifeq ($(CONFIG_RCW), "y")
	@$(call repo-mngr,fetch,rcw,bsp) && \
	 cd $(BSPDIR) && mkdir -p $(FBOUTDIR)/bsp/rcw
ifeq ($(MACHINE), all)
	@cd $(BSPDIR) && \
	 for brd in `find rcw -maxdepth 1 -type d -name "l*"|cut -d/ -f2`; do \
	     if [ $$brd = ls1088ardb_pb ]; then brd=ls1088ardb; fi && \
	     test -f rcw/$$brd/Makefile || continue; \
	     $(MAKE) -C rcw/$$brd && \
	     $(MAKE) -C rcw/$$brd install DESTDIR=$(FBOUTDIR)/bsp/rcw/$$brd; \
	 done
else
	@if [ $(MACHINE) = ls1088ardb_pb ]; then brd=ls1088ardb; else brd=$(MACHINE); fi && \
	 cd $(BSPDIR) && $(MAKE) -C rcw/$$brd && \
	 $(MAKE) -C rcw/$$brd install DESTDIR=$(FBOUTDIR)/bsp/rcw/$$brd
endif
	@rm -f $(FBOUTDIR)/bsp/rcw/*/README && $(call fbprint_d,"RCW")
endif

# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



restool:
ifeq ($(CONFIG_RESTOOL), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(SOCFAMILY) != LS -a $(DISTROTYPE) != ubuntu -a $(DISTROTYPE) != yocto -o \
	   $(DISTROSCALE) = desktop ] && exit || \
	 $(call repo-mngr,fetch,restool,apps/networking) && \
	 cd $(NETDIR)/restool && \
	 $(MAKE) clean && \
	 $(MAKE) -j$(JOBS) && \
	 $(MAKE) -j$(JOBS) install && \
	 $(call fbprint_d,"restool")
endif
endif

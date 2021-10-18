# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



wayland_protocols:
ifeq ($(CONFIG_WAYLAND), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) != desktop ] && exit || \
	 $(call fbprint_b,"wayland_protocols") && \
	 $(call repo-mngr,fetch,wayland_protocols,apps/graphics) && \
	 cd $(GRAPHICSDIR)/wayland_protocols && \
	 ./autogen.sh --prefix=/usr --host=aarch64-linux-gnu && \
	 $(MAKE) && $(MAKE) install && \
	 $(call fbprint_d,"wayland_protocols")
endif
endif

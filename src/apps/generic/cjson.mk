# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



cjson:
ifeq ($(CONFIG_CJSON), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -a $(DISTROTYPE) != debian -a $(DISTROTYPE) != yocto ] && exit || \
	 $(call fbprint_b,"cjson") && \
	 $(call repo-mngr,fetch,cjson,apps/generic) && \
	 cd $(GENDIR)/cjson && \
	 export CC=$(CROSS_COMPILE)gcc && \
	 rm -rf build && mkdir -p build && cd build && \
	 cmake -DCMAKE_INSTALL_PREFIX=/usr .. && \
	 $(MAKE) -j$(JOBS) && \
	 $(MAKE) install && \
	 $(call fbprint_d,"cjson")
endif
endif

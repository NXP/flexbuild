# Copyright 2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# Sample program to monitor i.MX GPU performance data


gputop:
ifeq ($(CONFIG_GPUTOP), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) != desktop ] && exit || \
	 $(call fbprint_b,"gputop") && \
	 $(call repo-mngr,fetch,gputop,apps/graphics) && \
	 cd $(GRAPHICSDIR) && \
	 if [ ! -d $(GRAPHICSDIR)/libgpuperfcnt ]; then \
            wget -q $(repo_libgpuperfcnt_bin_url) -O libgpuperfcnt.bin && \
             chmod +x libgpuperfcnt.bin && ./libgpuperfcnt.bin --auto-accept && \
             mv libgpuperfcnt-* libgpuperfcnt && rm -f libgpuperfcnt.bin; \
	 fi && \
	 rm -rf gputop/build && mkdir -p gputop/build && cd gputop/build && \
	 export CC=$(CROSS_COMPILE)gcc && \
	 cmake -DCMAKE_TOOLCHAIN_FILE=$(GRAPHICSDIR)/gputop/cmake/OEToolchainConfig.cmake \
	       -DGPUPERFCNT_INCLUDE_PATH=$(GRAPHICSDIR)/libgpuperfcnt/usr/include \
	       -DGPUPERFCNT_LIB_PATH=$(GRAPHICSDIR)/libgpuperfcnt/usr/lib .. && \
	 $(MAKE) -j$(JOBS) && $(MAKE) install && \
	 install -m 0444 ../man/* $(DESTDIR)/usr/local/share/man/man8/ && \
	 $(call fbprint_d,"gputop")
endif
endif

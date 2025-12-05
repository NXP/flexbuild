# Copyright 2021-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# Sample program to monitor i.MX GPU performance data


gputop: libgpuperfcnt
	@[ $${MACHINE:0:4} != imx8 ] && exit || \
	 $(call download_repo,gputop,apps/graphics) && \
	 $(call patch_apply,gputop,apps/graphics) && \
	 $(call fbprint_b,"gputop") && \
	 cd $(GRAPHICSDIR)/gputop && \
	 rm -rf build_$(DISTROTYPE)_$(ARCH) && \
	 mkdir -p build_$(DISTROTYPE)_$(ARCH) && \
	 cd build_$(DISTROTYPE)_$(ARCH) && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 cmake -DCMAKE_TOOLCHAIN_FILE=$(GRAPHICSDIR)/gputop/cmake/OEToolchainConfig.cmake \
	       -DGPUPERFCNT_INCLUDE_PATH=$(DESTDIR)/usr/include \
	       -DGPUPERFCNT_LIB_PATH=$(DESTDIR)/usr/lib .. $(LOG_MUTE) && \
	 $(MAKE) -j$(JOBS) $(LOG_MUTE) && $(MAKE) install $(LOG_MUTE) && \
	 install -m 0444 ../man/* $(DESTDIR)/usr/local/share/man/man8/ && \
	 $(call fbprint_d,"gputop")

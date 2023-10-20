# Copyright 2021-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# Tools for tracing OpenGL, Direct3D, and other graphics APIs
# http://apitrace.github.io

# need  GTest

apitrace:
ifeq ($(CONFIG_APITRACE),y)
	@[ $(DISTROVARIANT) != desktop ] && exit || \
	 $(call fbprint_b,"apitrace") && \
	 $(call repo-mngr,fetch,apitrace,apps/graphics) && \
	 cd $(UTILSDIR)/apitrace && \
	 \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
         export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)" && \
	 mkdir -p build_$(DISTROTYPE)_$(ARCH) && \
	 cd build_$(DISTROTYPE)_$(ARCH) && \
	 cmake .. -G "Unix Makefiles" \
		-DENABLE_GUI=OFF \
		-DENABLE_STATIC_LIBGCC=OFF \
		-DENABLE_STATIC_LIBSTDCXX=OFF \
		-DPython3_ROOT_DIR=/usr/bin/python3 \
		-DENABLE_STATIC_SNAPPY=ON \
		-DENABLE_X11=OFF \
		-DCMAKE_BUILD_TYPE=release && \
	 touch $(GENDIR)/apitrace/thirdparty/gtest/googletest/LICENSE && \
	 $(MAKE) -j$(JOBS) && \
	 $(call fbprint_d,"apitrace")
endif

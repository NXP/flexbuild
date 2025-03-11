# Copyright 2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# https://github.com/google/flatbuffers
# Memory Efficient Serialization Library

# The native version 2.0.8 of Debian 12 libflatbuffers-dev doesn't match the required version 23.5.26 used for NNStreamer build.


flatbuffers:
	@[ $(SOCFAMILY) != IMX -o $(DISTROVARIANT) = tiny -o $(DISTROVARIANT) = base ] && exit || \
	 $(call fbprint_b,"flatbuffers") && \
	 $(call repo-mngr,fetch,flatbuffers,apps/ml) && \
	 cd $(MLDIR)/flatbuffers && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)" && \
	 mkdir -p build_$(DISTROTYPE)_$(ARCH) && \
	 cmake  -S $(MLDIR)/flatbuffers \
		-B $(MLDIR)/flatbuffers/build_$(DISTROTYPE)_$(ARCH) \
		-DCMAKE_CXX_FLAGS="-I$(DESTDIR)/usr/include -I$(RFSDIR)/usr/include" \
		-DFLATBUFFERS_BUILD_TESTS=OFF \
		-DFLATBUFFERS_BUILD_SHAREDLIB=ON && \
	 cmake --build $(MLDIR)/flatbuffers/build_$(DISTROTYPE)_$(ARCH) -j$(JOBS) --target all && \
	 cmake --install build_$(DISTROTYPE)_$(ARCH) --prefix /usr && \
	 $(call fbprint_d,"flatbuffers")

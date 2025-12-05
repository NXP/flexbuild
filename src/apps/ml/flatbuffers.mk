# Copyright 2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# https://github.com/google/flatbuffers
# Memory Efficient Serialization Library

# The native version 2.0.8 of Debian 12 libflatbuffers-dev doesn't match the required version 23.5.26 used for NNStreamer build.
#
# Need to build twice, ons is for arm64, one is for x86_64


flatbuffers:
	@[ $(SOCFAMILY) != IMX  ] && exit || \
	 $(call download_repo,flatbuffers,apps/ml) && \
	 $(call patch_apply,flatbuffers,apps/ml) && \
	 $(call fbprint_b,"flatbuffers") && \
	 cd $(MLDIR)/flatbuffers && \
	 mkdir -p build_native && \
	 cmake -S $(MLDIR)/flatbuffers \
		   -B $(MLDIR)/flatbuffers/build_native \
		   -DFLATBUFFERS_BUILD_TESTS=OFF \
		   -DFLATBUFFERS_BUILD_SHAREDLIB=OFF \
		   -DFLATBUFFERS_BUILD_FLATC=ON $(LOG_MUTE) && \
	 cmake --build $(MLDIR)/flatbuffers/build_native -j$(JOBS) --target flatc $(LOG_MUTE) && \
	 install -Dm755 $(MLDIR)/flatbuffers/build_native/flatc /usr/local/bin/flatc; \
	 \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)" && \
	 mkdir -p build_$(DISTROTYPE)_$(ARCH) && \
	 cmake  -S $(MLDIR)/flatbuffers \
		-B $(MLDIR)/flatbuffers/build_$(DISTROTYPE)_$(ARCH) \
		-DCMAKE_CXX_FLAGS="-I$(DESTDIR)/usr/include -I$(RFSDIR)/usr/include" \
		-DFLATBUFFERS_BUILD_TESTS=OFF \
		-DFLATBUFFERS_BUILD_SHAREDLIB=ON $(LOG_MUTE) && \
	 cmake --build $(MLDIR)/flatbuffers/build_$(DISTROTYPE)_$(ARCH) -j$(JOBS) --target all $(LOG_MUTE) && \
	 cmake --install build_$(DISTROTYPE)_$(ARCH) --prefix /usr $(LOG_MUTE) && \
	 cp -rf $(MLDIR)/flatbuffers/build_$(DISTROTYPE)_$(ARCH)/libflatbuffers* $(RFSDIR)/usr/lib && \
	 $(call fbprint_d,"flatbuffers")

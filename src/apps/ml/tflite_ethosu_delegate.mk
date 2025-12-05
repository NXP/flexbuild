# Copyright 2023-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# TensorFlow Lite Ethos-u Delegate on imx93

# DEPEND: tensorflow-lite ethosu-driver-stack libpython3.13-dev
#
# TFLITE_BUILD_DIR was defined in src/apps/ml/tflite_neutron_delegate.mk as:
# TFLITE_BUILD_DIR = "$(MLDIR)"/tflite/build_debian_arm64
#


tflite_ethosu_delegate: tflite ethosu_driver_stack
#tflite_ethosu_delegate:
	@[ $${MACHINE:0:5} != imx93  ] && exit || \
	$(call download_repo,tflite_ethosu_delegate,apps/ml) && \
	$(call patch_apply,tflite_ethosu_delegate,apps/ml) && \
	$(call fbprint_b,"tflite_ethosu_delegate") && \
	cd $(MLDIR)/tflite_ethosu_delegate && \
	export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)" && \
	export CXXFLAGS="-O2 -pipe -g -fPIC -feliminate-unused-debug-types -I$(DESTDIR)/usr/include" && \
	if [ -d "build_$(DISTROTYPE)_$(ARCH)" ]; then \
		cmake --build build_$(DISTROTYPE)_$(ARCH) --target clean; \
		cd build_$(DISTROTYPE)_$(ARCH); \
		rm -rf CMakeCache.txt Makefile cmake_install.cmake compile_commands.json \
			CMakeFiles bin lib/*.so* lib/*.a \
			example_proto_generated examples/*.o tools/*.o tmp/*; \
		find . -type d -name "CMakeFiles" -exec rm -rf {} +; \
		cd ..; \
	fi && \
	cmake  -S $(MLDIR)/tflite_ethosu_delegate \
		-B build_$(DISTROTYPE)_$(ARCH) -Wno-dev \
		-DPSIMD_SOURCE_DIR=$(TFLITE_BUILD_DIR)/psimd-source \
		-DFP16_SOURCE_DIR=$(TFLITE_BUILD_DIR)/FP16-source \
		-DFXDIV_SOURCE_DIR=$(TFLITE_BUILD_DIR)/FXdiv-source \
		-DPTHREADPOOL_SOURCE_DIR=$(TFLITE_BUILD_DIR)/pthreadpool-source \
		-DFARMHASH_SOURCE_DIR=$(TFLITE_BUILD_DIR)/farmhash \
		-DFETCHCONTENT_SOURCE_DIR_FLATBUFFERS=$(TFLITE_BUILD_DIR)/flatbuffers \
		-DFETCHCONTENT_SOURCE_DIR_RUY=$(TFLITE_BUILD_DIR)/ruy \
		-DFETCHCONTENT_SOURCE_DIR_XNNPACK=$(TFLITE_BUILD_DIR)/xnnpack \
		-DFETCHCONTENT_SOURCE_DIR_GEMMLOWP=$(TFLITE_BUILD_DIR)/gemmlowp \
		-DFETCHCONTENT_SOURCE_DIR_ABSEIL-CPP=$(TFLITE_BUILD_DIR)/abseil-cpp \
		-DFETCHCONTENT_SOURCE_DIR_CPUINFO=$(TFLITE_BUILD_DIR)/cpuinfo \
		-DFETCHCONTENT_SOURCE_DIR_EIGEN=$(TFLITE_BUILD_DIR)/eigen \
		-DFETCHCONTENT_FULLY_DISCONNECTED=OFF \
		-DFETCHCONTENT_SOURCE_DIR_TENSORFLOW=$(MLDIR)/tflite \
		-DTFLITE_LIB_LOC=$(DESTDIR)/usr/lib/libtensorflow-lite.so \
		-DPython_INCLUDE_DIRS=$(RFSDIR)/usr/include/python3.13 \
		-DPython_EXECUTABLE=$(RFSDIR)/usr/bin/python3.13 \
		-DPython_LIBRARY=$(RFSDIR)/usr/lib/aarch64-linux-gnu/libpython3.13.so $(LOG_MUTE) && \
	$(MAKE) -j$(JOBS) -C build_$(DISTROTYPE)_$(ARCH) ethosu_delegate $(LOG_MUTE) && \
	$(CROSS_COMPILE)strip build_$(DISTROTYPE)_$(ARCH)/libethosu_delegate.so && \
	install -m 0644 build_$(DISTROTYPE)_$(ARCH)/libethosu_delegate.so $(DESTDIR)/usr/lib && \
	$(call fbprint_d,"tflite_ethosu_delegate")

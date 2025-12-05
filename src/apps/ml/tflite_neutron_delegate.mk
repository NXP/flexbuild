# Copyright 2025 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# DEPEND: tensorflow-lite neutron

TFLITE_BUILD_DIR = "$(MLDIR)"/tflite/build_debian_arm64

#tflite_neutron_delegate:
tflite_neutron_delegate: tflite neutron
	@[ $${MACHINE:0:5} != imx95 ] && exit || \
	$(call download_repo,tflite_neutron_delegate,apps/ml) && \
	$(call patch_apply,tflite_neutron_delegate,apps/ml) && \
	$(call fbprint_b,"tflite_neutron_delegate") && \
	export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)" && \
	export CXXFLAGS="-O2 -pipe -g -fPIC -feliminate-unused-debug-types -I$(DESTDIR)/usr/include" && \
	export CFLAGS="-O2 -pipe -g -fPIC -feliminate-unused-debug-types -I$(DESTDIR)/usr/include" && \
	export CMAKE_TLS_VERIFY=0 && \
	ln -sf /usr/aarch64-linux-gnu/lib/ld-linux-aarch64.so.1 /lib/ld-linux-aarch64.so.1 && \
	mkdir -p $(RFSDIR)/usr/include/neutron && \
	cp -f $(DESTDIR)/usr/include/neutron/* $(RFSDIR)/usr/include/neutron && \
	cp -f $(DESTDIR)/usr/lib/libNeutronDriver* $(RFSDIR)/usr/lib/ && \
	cd $(MLDIR)/tflite_neutron_delegate && \
	if [ -d "build_$(DISTROTYPE)_$(ARCH)" ]; then \
		cmake --build build_$(DISTROTYPE)_$(ARCH) --target clean; \
		cd build_$(DISTROTYPE)_$(ARCH); \
		rm -rf CMakeCache.txt Makefile cmake_install.cmake compile_commands.json \
			CMakeFiles bin lib/*.so* lib/*.a \
			example_proto_generated examples/*.o tools/*.o tmp/*; \
		find . -type d -name "CMakeFiles" -exec rm -rf {} +; \
		cd ..; \
	fi && \
	cmake  -S $(MLDIR)/tflite_neutron_delegate \
		-B build_$(DISTROTYPE)_$(ARCH) \
		-DPSIMD_SOURCE_DIR=$(TFLITE_BUILD_DIR)/psimd-source \
		-DKLEIDIAI_SOURCE_DIR=$(TFLITE_BUILD_DIR)/kleidiai-source \
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
		-Wno-dev -DCMAKE_POLICY_DEFAULT_CMP0169=OLD \
		-DCMAKE_SYSTEM_NAME=Linux \
		-DTFLITE_HOST_TOOLS_DIR="/usr" \
		-DCMAKE_SYSTEM_PROCESSOR=aarch64 \
		-DXNNPACK_TARGET_PROCESSOR=arm64 \
		-DCMAKE_C_FLAGS="-DCPUINFO_ARCH_ARM64=1 -DCPUINFO_ARCH_X86=0 -I$(DESTDIR)/usr/include -L$(DESTDIR)/usr/lib -lNeutronDriver" \
		-DCMAKE_CXX_FLAGS="-DCPUINFO_ARCH_ARM64=1 -DCPUINFO_ARCH_X86=0 -I$(DESTDIR)/usr/include -L$(DESTDIR)/usr/lib -lNeutronDriver" \
		-DCMAKE_BUILD_TYPE=Release \
		-DFETCHCONTENT_FULLY_DISCONNECTED=OFF \
		-DFETCHCONTENT_SOURCE_DIR_TENSORFLOW=$(MLDIR)/tflite \
		-DTENSORFLOW_SOURCE_DIR=$(MLDIR)/tflite \
		-DTFLITE_LIB_LOC=$(DESTDIR)/usr/lib/libtensorflow-lite.so \
		-DPython_EXECUTABLE=$(RFSDIR)/usr/bin/python3.13 \
		-DCMAKE_EXE_LINKER_FLAGS="-L$(DESTDIR)/usr/lib" $(LOG_MUTE) && \
	 $(MAKE) -j$(JOBS) -C build_$(DISTROTYPE)_$(ARCH) $(LOG_MUTE) && \
	 rm -f /lib/ld-linux-aarch64.so.1 && \
	 $(CROSS_COMPILE)strip build_$(DISTROTYPE)_$(ARCH)/libneutron_delegate.so && \
	 install -m 0644 build_$(DISTROTYPE)_$(ARCH)/libneutron_delegate.so $(DESTDIR)/usr/lib && \
	 $(call fbprint_d,"tflite_neutron_delegate")

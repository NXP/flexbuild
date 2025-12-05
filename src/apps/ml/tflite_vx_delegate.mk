# Copyright 2023-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# TensorFlow Lite VX Delegate used on imx8*

# DEPEND: tensorflow-lite tim-vx

# ./benchmark_model --external_delegate_path=<patch_to_libvx_delegate.so> --graph=<tflite_model.tflite>

#
# TFLITE_BUILD_DIR was defined in src/apps/ml/tflite_neutron_delegate.mk as:
# TFLITE_BUILD_DIR = "$(MLDIR)"/tflite/build_debian_arm64
#


#tflite_vx_delegate:
tflite_vx_delegate: tflite tim_vx
	@[ $${MACHINE:0:5} != imx8m  ] && exit || \
	$(call download_repo,tflite_vx_delegate,apps/ml) && \
	$(call patch_apply,tflite_vx_delegate,apps/ml) && \
	$(call fbprint_b,"tflite_vx_delegate") && \
	cd $(MLDIR)/tflite_vx_delegate && \
	export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)" && \
	export CXXFLAGS="-O2 -pipe -g -fPIC -feliminate-unused-debug-types -I$(RFSDIR)//usr/include/python3.13" && \
	if [ -d "build_$(DISTROTYPE)_$(ARCH)" ]; then \
		cmake --build build_$(DISTROTYPE)_$(ARCH) --target clean; \
		cd build_$(DISTROTYPE)_$(ARCH); \
		rm -rf CMakeCache.txt Makefile cmake_install.cmake compile_commands.json \
			CMakeFiles bin lib/*.so* lib/*.a \
			example_proto_generated examples/*.o tools/*.o tmp/*; \
		find . -type d -name "CMakeFiles" -exec rm -rf {} +; \
		cd ..; \
	fi && \
	cmake  -S $(MLDIR)/tflite_vx_delegate \
		-B build_$(DISTROTYPE)_$(ARCH) -Wno-dev \
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
		-DFETCHCONTENT_FULLY_DISCONNECTED=OFF \
		-DCMAKE_SYSTEM_NAME=Linux \
		-DTFLITE_HOST_TOOLS_DIR="/usr" \
		-DCMAKE_SYSTEM_PROCESSOR=aarch64 \
		-DXNNPACK_TARGET_PROCESSOR=arm64 \
		-DTIM_VX_INSTALL=$(DESTDIR)/usr \
		-DFETCHCONTENT_SOURCE_DIR_TENSORFLOW=$(MLDIR)/tflite \
		-DTFLITE_LIB_LOC=$(DESTDIR)/usr/lib/libtensorflow-lite.so $(LOG_MUTE) && \
	$(MAKE) -j$(JOBS) -C build_$(DISTROTYPE)_$(ARCH) vx_delegate $(LOG_MUTE) && \
	$(CROSS_COMPILE)strip build_$(DISTROTYPE)_$(ARCH)/libvx_delegate.so && \
	cp -f build_$(DISTROTYPE)_$(ARCH)/libvx_delegate.so $(DESTDIR)/usr/lib && \
	install -d $(DESTDIR)/usr/include/tensorflow-lite-vx-delegate && \
	cp --parents vsi_npu_custom_op.h op_map.h utils.h delegate_main.h examples/util.h \
	   $(DESTDIR)/usr/include/tensorflow-lite-vx-delegate && \
	$(call fbprint_d,"tflite_vx_delegate")

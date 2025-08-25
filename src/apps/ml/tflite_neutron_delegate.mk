# Copyright 2023-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# TensorFlow Lite Ethos-u Delegate on imx93

# DEPEND: tensorflow-lite ethosu-driver-stack libpython3.13-dev


#tflite_neutron_delegate:
tflite_neutron_delegate: tflite neutron
	@[ $${MACHINE:0:5} != imx95 ] && exit || \
	$(call download_repo,tflite_neutron_delegate,apps/ml) && \
	$(call patch_apply,tflite_neutron_delegate,apps/ml) && \
	$(call fbprint_b,"tflite_neutron_delegate") && \
	cd $(MLDIR)/tflite_neutron_delegate && \
	echo $(CROSS_COMPILE) && \
	export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)" && \
	export CXXFLAGS="-O2 -pipe -g -fPIC -feliminate-unused-debug-types -I$(DESTDIR)/usr/include" && \
	export CFLAGS="-O2 -pipe -g -fPIC -feliminate-unused-debug-types -I$(DESTDIR)/usr/include" && \
	export CMAKE_TLS_VERIFY=0 && \
	ln -sf /usr/aarch64-linux-gnu/lib/ld-linux-aarch64.so.1 /lib/ld-linux-aarch64.so.1 && \
	rm -rf build_$(DISTROTYPE)_$(ARCH) && \
	mkdir -p build_$(DISTROTYPE)_$(ARCH) && \
	cmake  -S $(MLDIR)/tflite_neutron_delegate \
		-B $(MLDIR)/tflite_neutron_delegate/build_$(DISTROTYPE)_$(ARCH) \
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
		-DTFLITE_LIB_LOC=$(DESTDIR)/usr/lib/libtensorflow-lite.so \
		-DPython_EXECUTABLE=$(RFSDIR)/usr/bin/python3.13 \
		-DCMAKE_EXE_LINKER_FLAGS="-L$(DESTDIR)/usr/lib" $(LOG_MUTE) && \
	 $(MAKE) -j$(JOBS) -C build_$(DISTROTYPE)_$(ARCH) $(LOG_MUTE) && \
	 rm -f /lib/ld-linux-aarch64.so.1 && \
	 $(CROSS_COMPILE)strip build_$(DISTROTYPE)_$(ARCH)/libneutron_delegate.so && \
	 install -m 0644 build_$(DISTROTYPE)_$(ARCH)/libneutron_delegate.so $(DESTDIR)/usr/lib && \
	 $(call fbprint_d,"tflite_neutron_delegate")

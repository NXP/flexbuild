# Copyright 2023-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# TensorFlow Lite Ethos-u Delegate on imx93

# DEPEND: tensorflow-lite ethosu-driver-stack libpython3.11-dev


tflite_ethosu_delegate:
	@[ $(SOCFAMILY) != IMX -o $(DISTROVARIANT) = tiny -o $(DISTROVARIANT) = base ] && exit || \
	 $(call fbprint_b,"tflite_ethosu_delegate") && \
	 $(call repo-mngr,fetch,tflite_ethosu_delegate,apps/ml) && \
	 if [ ! -f $(DESTDIR)/usr/lib/libtensorflow-lite.so ]; then \
	     bld tflite -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/libethosu.so ]; then \
	     bld ethosu_driver_stack -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 cd $(MLDIR)/tflite_ethosu_delegate && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)" && \
	 export CXXFLAGS="-O2 -pipe -g -fPIC -feliminate-unused-debug-types -I$(DESTDIR)/usr/include" && \
	 mkdir -p build_$(DISTROTYPE)_$(ARCH) && \
	 cmake  -S $(MLDIR)/tflite_ethosu_delegate \
		-B $(MLDIR)/tflite_ethosu_delegate/build_$(DISTROTYPE)_$(ARCH) \
		-DFETCHCONTENT_FULLY_DISCONNECTED=OFF \
		-DFETCHCONTENT_SOURCE_DIR_TENSORFLOW=$(MLDIR)/tflite \
		-DTFLITE_LIB_LOC=$(DESTDIR)/usr/lib/libtensorflow-lite.so \
		-DPython_INCLUDE_DIRS=$(RFSDIR)/usr/include/python3.11 \
		-DPython_EXECUTABLE=$(RFSDIR)/usr/bin/python3.11 \
		-DPython_LIBRARY=$(RFSDIR)/usr/lib/aarch64-linux-gnu/libpython3.11.so && \
	 $(MAKE) -j$(JOBS) -C build_$(DISTROTYPE)_$(ARCH) ethosu_delegate && \
	 $(CROSS_COMPILE)strip build_$(DISTROTYPE)_$(ARCH)/libethosu_delegate.so && \
	 install -m 0644 build_$(DISTROTYPE)_$(ARCH)/libethosu_delegate.so $(DESTDIR)/usr/lib && \
	 $(call fbprint_d,"tflite_ethosu_delegate")

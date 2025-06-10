# Copyright 2023-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# TensorFlow Lite VX Delegate

# DEPEND: tensorflow-lite tim-vx

# ./benchmark_model --external_delegate_path=<patch_to_libvx_delegate.so> --graph=<tflite_model.tflite>



tflite_vx_delegate: tflite tim_vx
	@[ $(SOCFAMILY) != IMX -o $(DISTROVARIANT) = tiny -o $(DISTROVARIANT) = base ] && exit || \
	 $(call repo-mngr,fetch,tflite_vx_delegate,apps/ml) && \
	 if [ ! -f $(DESTDIR)/usr/lib/libtensorflow-lite.so ]; then \
	     bld tflite -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/libtim-vx.so ]; then \
	     bld tim_vx -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 $(call fbprint_b,"tflite_vx_delegate") && \
	 cd $(MLDIR)/tflite_vx_delegate && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)" && \
	 export CXXFLAGS="-O2 -pipe -g -fPIC -feliminate-unused-debug-types -I$(RFSDIR)//usr/include/python3.11" && \
	 mkdir -p build_$(DISTROTYPE)_$(ARCH) && \
	 cmake  -S $(MLDIR)/tflite_vx_delegate \
		-B $(MLDIR)/tflite_vx_delegate/build_$(DISTROTYPE)_$(ARCH) \
		-DFETCHCONTENT_FULLY_DISCONNECTED=OFF \
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

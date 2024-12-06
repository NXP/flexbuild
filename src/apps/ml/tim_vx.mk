# Copyright 2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# Tensor Interface Module for OpenVX
# TIM-VX is a software integration module provided by VeriSilicon to facilitate deployment of Neural-Networks on OpenVX enabled ML accelerators.
# It serves as the backend binding for runtime frameworks such as Android NN, Tensorflow-Lite, MLIR, TVM and more


# DEPEND: gpu_viv


tim_vx:
	@[ $(SOCFAMILY) != IMX -o $(DISTROVARIANT) = tiny -o $(DISTROVARIANT) = base ] && exit || \
	 $(call fbprint_b,"tim_vx") && \
	 $(call repo-mngr,fetch,tim_vx,apps/ml) && \
	 if [ ! -f $(DESTDIR)/usr/lib/libOpenVX.so ]; then \
	     bld gpu_viv -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 cd $(MLDIR)/tim_vx && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(DESTDIR)" && \
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(DESTDIR)" && \
	 mkdir -p $(DESTDIR)/usr/include/VX && \
	 cp -f prebuilt-sdk/*linux/include/VX/vx_khr_cnn.h $(DESTDIR)/usr/include/VX && \
	 mkdir -p build_$(DISTROTYPE)_$(ARCH) && \
	 cmake  -S $(MLDIR)/tim_vx \
		-B $(MLDIR)/tim_vx/build_$(DISTROTYPE)_$(ARCH) \
		-DCMAKE_C_FLAGS="-I$(DESTDIR)/usr/include -I$(RFSDIR)/usr/include" \
		-DCONFIG=YOCTO \
		-DTIM_VX_ENABLE_TEST=off \
		-DTIM_VX_USE_EXTERNAL_OVXLIB=off && \
	 cmake --build $(MLDIR)/tim_vx/build_$(DISTROTYPE)_$(ARCH) --target all && \
	 $(CROSS_COMPILE)strip build_$(DISTROTYPE)_$(ARCH)/src/tim/libtim-vx.so && \
	 cp build_$(DISTROTYPE)_$(ARCH)/src/tim/libtim-vx.so $(DESTDIR)/usr/lib && \
	 install -d $(DESTDIR)/usr/include/tim && \
	 cp -rf $(MLDIR)/tim_vx/include/tim/{transform,vx} $(DESTDIR)/usr/include/tim && \
	 $(call fbprint_d,"tim_vx")

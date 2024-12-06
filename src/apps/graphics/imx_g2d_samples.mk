# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# Set of sample applications for i.MX G2D


# PXP on imx93
# DPU on imx8dx, imx8qxp, imx8qm
# GPU on others

ifeq ($(MACHINE),imx93evk)
  BUILD_IMPLEMENTATION = pxp
else ifeq ($(MACHINE),imx8qm)
  BUILD_IMPLEMENTATION = dpu
else ifeq ($(MACHINE),imx8dx)
  BUILD_IMPLEMENTATION = dpu
else ifeq ($(MACHINE),imx8qxp)
  BUILD_IMPLEMENTATION = dpu
else
  BUILD_IMPLEMENTATION = gpu-drm
endif


imx_g2d_samples:
	@[ $(DISTROVARIANT) != desktop -o $(SOCFAMILY) != IMX ] && exit || \
	 $(call fbprint_b,"imx_g2d_samples for $(BUILD_IMPLEMENTATION)") && \
	 $(call repo-mngr,fetch,imx_g2d_samples,apps/graphics) && \
	 \
	 if [ ! -f $(DESTDIR)/usr/lib/libg2d.so.2 ]; then \
	     bld imx_gpu_g2d -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 cd $(GRAPHICSDIR)/imx_g2d_samples && \
	 sudo cp $(DESTDIR)/usr/lib/{libOpenCL.so*,libSPIRV_viv.so*} $(RFSDIR)/usr/lib && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export BUILD_IMPLEMENTATION=$(BUILD_IMPLEMENTATION) && \
	 export SDKTARGETSYSROOT=$(RFSDIR) && \
	 export CFLAGS="-I$(DESTDIR)/usr/include" && \
	 export LDFLAGS="-L$(DESTDIR)/usr/lib" && \
	 $(MAKE) clean && \
	 $(MAKE) -j$(JOBS) && \
	 $(MAKE) -j$(JOBS) install DESTDIR=$(DESTDIR) && \
	 $(call fbprint_d,"imx_g2d_samples")

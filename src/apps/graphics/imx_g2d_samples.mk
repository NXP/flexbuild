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


imx_g2d_samples: imx_gpu_g2d
	@[ $(SOCFAMILY) != IMX ] && exit || \
	 $(call download_repo,imx_g2d_samples,apps/graphics) && \
	 $(call patch_apply,imx_g2d_samples,apps/graphics) && \
	 $(call fbprint_b,"imx_g2d_samples for $(BUILD_IMPLEMENTATION)") && \
	 cd $(GRAPHICSDIR)/imx_g2d_samples && \
	 sudo cp $(DESTDIR)/usr/lib/{libOpenCL.so*,libSPIRV_viv.so*} $(RFSDIR)/usr/lib && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export BUILD_IMPLEMENTATION=$(BUILD_IMPLEMENTATION) && \
	 export SDKTARGETSYSROOT=$(RFSDIR) && \
	 export CFLAGS="-I$(DESTDIR)/usr/include" && \
	 export LDFLAGS="-L$(DESTDIR)/usr/lib" && \
	 $(MAKE) clean && \
	 $(MAKE) -j$(JOBS) $(LOG_MUTE) && \
	 $(MAKE) -j$(JOBS) install DESTDIR=$(DESTDIR) $(LOG_MUTE) && \
	 $(call fbprint_d,"imx_g2d_samples")

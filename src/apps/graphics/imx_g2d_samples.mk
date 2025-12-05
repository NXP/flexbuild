# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# Set of sample applications for i.MX G2D


# PXP on imx93
# DPU on imx8dx, imx8qxp, imx8qm
# GPU on others

ifeq ($(filter imx95%,$(MACHINE)),$(MACHINE))
	DEP_G2D = imx_dpu_g2d_v2
	BUILD_IMPLEMENTATION = dpu95
else ifeq ($(filter imx91%,$(MACHINE)),$(MACHINE))
	DEP_G2D = imx_pxp_g2d
	BUILD_IMPLEMENTATION = pxp
else ifeq ($(filter imx93%,$(MACHINE)),$(MACHINE))
	DEP_G2D = imx_pxp_g2d
	BUILD_IMPLEMENTATION = pxp
else ifeq ($(filter imx943%,$(MACHINE)),$(MACHINE))
	DEP_G2D = imx_pxp_g2d
	BUILD_IMPLEMENTATION = pxp
else ifeq ($(filter imx8%,$(MACHINE)),$(MACHINE))
	DEP_G2D = imx_gpu_g2d gpu_viv imx_dpu_g2d_v1
	BUILD_IMPLEMENTATION = gpu-drm
else
	DEP_G2D =
	BUILD_IMPLEMENTATION =
endif


imx_g2d_samples: $(DEP_G2D)
	@[ $(SOCFAMILY) != IMX ] && exit || \
	 $(call download_repo,imx_g2d_samples,apps/graphics) && \
	 $(call patch_apply,imx_g2d_samples,apps/graphics) && \
	 $(call fbprint_b,"imx_g2d_samples for $(BUILD_IMPLEMENTATION)") && \
	 cd $(GRAPHICSDIR)/imx_g2d_samples && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export BUILD_IMPLEMENTATION=$(BUILD_IMPLEMENTATION) && \
	 export SDKTARGETSYSROOT=$(RFSDIR) && \
	 export CFLAGS="-I$(DESTDIR)/usr/include" && \
	 export LDFLAGS="-L$(DESTDIR)/usr/lib -Wl,-rpath-link=$(DESTDIR)/usr/lib" && \
	 $(MAKE) clean && \
	 $(MAKE) -j$(JOBS) $(LOG_MUTE) && \
	 $(MAKE) -j$(JOBS) install DESTDIR=$(DESTDIR) $(LOG_MUTE) && \
	 $(call fbprint_d,"imx_g2d_samples")

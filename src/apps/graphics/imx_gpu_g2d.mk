# Copyright 2021-2024,2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# GPU G2D library and apps for i.MX with 2D GPU

# GC520L                            -> imx-gpu-g2d : 8mm, 8mp, 8ulp

imx_gpu_g2d:
	@$(call dl_by_wget,imx_gpu_g2d_bin,imx_gpu_g2d.bin)
	cd $(GRAPHICSDIR)
	if [ ! -d "$(GRAPHICSDIR)"/imx_gpu_g2d ]; then \
		chmod +x $(FBDIR)/dl/imx_gpu_g2d.bin; \
		$(FBDIR)/dl/imx_gpu_g2d.bin --auto-accept --force $(LOG_MUTE); \
		mv imx-gpu-g2d-* imx_gpu_g2d; \
	fi
	$(call fbprint_b,"imx_gpu_g2d")
	cd imx_gpu_g2d
	cp -af g2d/usr "$(DESTDIR)/"
	$(call fbprint_d,"imx_gpu_g2d")

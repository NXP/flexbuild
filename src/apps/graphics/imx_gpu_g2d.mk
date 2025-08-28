# Copyright 2021-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# GPU G2D library and apps for i.MX with 2D GPU

# COMPATIBLE_MACHINE: imx8mm

imx_gpu_g2d:
	@[ $${MACHINE:0:4} != imx8 -a $${MACHINE:0:6} != ls1028 -o $(DISTROVARIANT) = base -o $(DISTROVARIANT) = tiny ] && exit || \
	 $(call fbprint_b,"imx_gpu_g2d") && \
	 cd $(GRAPHICSDIR) && \
	 if [ ! -d $(GRAPHICSDIR)/imx_gpu_g2d ]; then \
		 rm -rf imx_gpu_g2d*; \
	     $(WGET) $(repo_imx_gpu_g2d_bin_url) -O imx_gpu_g2d.bin $(LOG_MUTE); \
		 [ $$? -ne 0 ] && { echo "Downloading $(repo_imx_gpu_g2d_bin_url) failed."; exit 1; } || \
	     chmod +x imx_gpu_g2d.bin && ./imx_gpu_g2d.bin --auto-accept --force $(LOG_MUTE); \
	     mv imx-gpu-g2d-* imx_gpu_g2d && rm -f imx_gpu_g2d.bin; \
	 fi && \
	 cd imx_gpu_g2d && \
	 cp -af g2d/usr "$(DESTDIR)/" && \
	 $(call fbprint_d,"imx_gpu_g2d")

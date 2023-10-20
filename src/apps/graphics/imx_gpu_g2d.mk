# Copyright 2021-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# GPU G2D library and apps for i.MX with 2D GPU and no DPU


imx_gpu_g2d:
	@[ $(DESTARCH) != arm64 -o $(DISTROVARIANT) != desktop ] && exit || \
	 $(call fbprint_b,"imx_gpu_g2d") && \
	 cd $(GRAPHICSDIR) && \
	 if [ ! -d $(GRAPHICSDIR)/imx_gpu_g2d ]; then \
	     wget -q $(repo_imx_gpu_g2d_bin_url) -O imx_gpu_g2d.bin && \
	     chmod +x imx_gpu_g2d.bin && ./imx_gpu_g2d.bin --auto-accept && \
	     mv imx-gpu-g2d-* imx_gpu_g2d && rm -f imx_gpu_g2d.bin; \
	 fi && \
	 cd imx_gpu_g2d && \
	 cp -Pr g2d/usr/include/* $(DESTDIR)/usr/include/ && \
	 cp -Pf g2d/usr/lib/libg2d-viv.so.* $(DESTDIR)/usr/lib/ && \
	 ln -sf libg2d.so.2 $(DESTDIR)/usr/lib/libg2d.so && \
	 ln -sf libg2d-viv.so.2.1.0 $(DESTDIR)/usr/lib/libg2d.so.2 && \
	 $(call fbprint_d,"imx_gpu_g2d")

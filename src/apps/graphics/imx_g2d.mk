# Copyright 2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# GPU G2D library and apps for i.MX with 2D GPU and no DPU


imx_g2d:
ifeq ($(CONFIG_IMX_G2D), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) != desktop ] && exit || true && \
	 $(call fbprint_b,"imx_g2d") && \
	 cd $(GRAPHICSDIR) && \
	 if [ ! -d $(GRAPHICSDIR)/imx_g2d ]; then \
	     wget -q $(repo_imx_g2d_bin_url) -O imx_g2d.bin && \
	     chmod +x imx_g2d.bin && ./imx_g2d.bin --auto-accept && \
	     mv imx-gpu-g2d-* imx_g2d && rm -f imx_g2d.bin; \
	 fi && \
	 cd imx_g2d && \
	 cp -Pf g2d/usr/lib/*.so* $(DESTDIR)/usr/lib/ && \
	 cp -Pr g2d/usr/include/* $(DESTDIR)/usr/include/ && \
	 cp -fr gpu-demos/opt $(DESTDIR)/ && \
	 ln -sf libg2d-viv.so.1.6.0 $(DESTDIR)/usr/lib/libg2d-viv.so && \
	 $(call fbprint_d,"imx_g2d")
endif
endif

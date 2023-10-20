# Copyright 2021-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# G2D library using i.MX DPU on imx8dx, imx8qxp, imx8qm
#
# DEPENDS: libgal-imx libdrm


imx_dpu_g2d:
ifeq ($(MACHINE),imx8qmmek)
	@[ $(DESTARCH) != arm64 -o $(DISTROVARIANT) != desktop ] && exit || \
	 $(call fbprint_b,"imx_dpu_g2d") && \
	 cd $(GRAPHICSDIR) && \
	 if [ ! -d $(GRAPHICSDIR)/imx_dpu_g2d ]; then \
	     wget -q $(repo_imx_dpu_g2d_bin_url) -O imx_dpu_g2d.bin && \
	     chmod +x imx_dpu_g2d.bin && ./imx_dpu_g2d.bin --auto-accept && \
	     mv imx-dpu-g2d-* imx_dpu_g2d && rm -f imx_dpu_g2d.bin; \
	 fi && \
	 cd imx_dpu_g2d && \
	 cp -Pf g2d/usr/lib/*.so* $(DESTDIR)/usr/lib/ && \
	 cp -Pr g2d/usr/include/* $(DESTDIR)/usr/include/ && \
	 $(call fbprint_d,"imx_dpu_g2d")
endif

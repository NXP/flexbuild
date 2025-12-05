# Copyright 2021-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# G2D library using i.MX DPU on imx95
#
# DEPENDS: libgal-imx libdrm


imx_dpu_g2d_v2:
	@[ $${MACHINE:0:5} != imx95 ] && exit || \
	$(call dl_by_wget,imx_dpu_g2d_bin_v2,imx_dpu_g2d_v2.bin) && \
	cd $(GRAPHICSDIR) && \
	if [ ! -d "$(GRAPHICSDIR)"/imx_dpu_g2d_v2 ]; then \
		chmod +x $(FBDIR)/dl/imx_dpu_g2d_v2.bin; \
		$(FBDIR)/dl/imx_dpu_g2d_v2.bin --auto-accept --force $(LOG_MUTE); \
		mv imx-dpu-g2d-* imx_dpu_g2d_v2; \
	fi && \
	$(call fbprint_b,"imx_dpu_g2d_v2") && \
	cd imx_dpu_g2d_v2 && \
	cp -Pf g2d/usr/lib/*.so* $(DESTDIR)/usr/lib/ && \
	cp -Pr g2d/usr/include/* $(DESTDIR)/usr/include/ && \
	$(call fbprint_d,"imx_dpu_g2d_v2")

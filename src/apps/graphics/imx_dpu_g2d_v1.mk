# Copyright 2021-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# G2D library using i.MX DPU on imx8dx, imx8qxp, imx8qm imx95
#
# DEPENDS: libgal-imx libdrm
# High Perf 2D Blit Engine -> imx-dpu-g2d-v1: imx8dxp imx8dx imx8qp imx8qm


imx_dpu_g2d_v1:
	@[ $${MACHINE:0:5} != imx8q -a $${MACHINE:0:5} != imx8d ] && exit || \
	$(call dl_by_wget,imx_dpu_g2d_bin_v1,imx_dpu_g2d_v1.bin) && \
	cd $(GRAPHICSDIR) && \
	if [ ! -d "$(GRAPHICSDIR)"/imx_dpu_g2d_v1 ]; then \
		chmod +x $(FBDIR)/dl/imx_dpu_g2d_v1.bin; \
		$(FBDIR)/dl/imx_dpu_g2d_v1.bin --auto-accept --force $(LOG_MUTE); \
		mv imx-dpu-g2d-* imx_dpu_g2d_v1; \
	fi && \
	$(call fbprint_b,"imx_dpu_g2d_v1") && \
	cd imx_dpu_g2d_v1 && \
	cp -Pf g2d/usr/lib/*.so* $(DESTDIR)/usr/lib/ && \
	cp -Pr g2d/usr/include/* $(DESTDIR)/usr/include/ && \
	$(call fbprint_d,"imx_dpu_g2d_v1")

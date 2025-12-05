# Copyright 2021-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# i.MX vc8000e encoder library on imx8mp


imx_vpu_hantro_vc:
	@[ $(SOCFAMILY) != IMX ] && exit || \
	$(call dl_by_wget,vpu_hantro_vc_bin,vpu_hantro_vc.bin) && \
	cd $(MMDIR) && \
	if [ ! -d "$(MMDIR)"/imx_vpu_hantro_vc ]; then \
		chmod +x $(FBDIR)/dl/vpu_hantro_vc.bin; \
		$(FBDIR)/dl/vpu_hantro_vc.bin --auto-accept --force $(LOG_MUTE); \
		mv imx-vpu-hantro-vc-* imx_vpu_hantro_vc; \
	fi && \
	$(call fbprint_b,"imx_vpu_hantro_vc") && \
	cp -Prf $(MMDIR)/imx_vpu_hantro_vc/usr $(DESTDIR)/ && \
	cp -Prf $(MMDIR)/imx_vpu_hantro_vc/unit_tests $(DESTDIR) && \
	$(call fbprint_d,"imx_vpu_hantro_vc")

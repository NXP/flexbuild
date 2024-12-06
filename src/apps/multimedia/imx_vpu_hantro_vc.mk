# Copyright 2021-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# i.MX vc8000e encoder library on imx8mp


imx_vpu_hantro_vc:
	@[ $(DISTROVARIANT) != desktop -o $(SOCFAMILY) != IMX ] && exit || \
	 $(call fbprint_b,"imx_vpu_hantro_vc") && \
	 cd $(MMDIR) && \
	 if [ ! -d imx_vpu_hantro_vc ]; then \
	     cd $(MMDIR) && wget -q $(repo_vpu_hantro_vc_bin_url) -O vpu_hantro_vc.bin && \
	     chmod +x vpu_hantro_vc.bin && \
	     ./vpu_hantro_vc.bin --auto-accept && \
	     mv imx-vpu-hantro-vc-* imx_vpu_hantro_vc && rm -f vpu_hantro_vc.bin; \
	 fi && \
	 cp -Prf $(MMDIR)/imx_vpu_hantro_vc/usr $(DESTDIR)/ && \
	 cp -Prf $(MMDIR)/imx_vpu_hantro_vc/unit_tests $(DESTDIR) && \
	 $(call fbprint_d,"imx_vpu_hantro_vc")

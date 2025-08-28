# Copyright 2021-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# i.MX vc8000e encoder library on imx8mp


imx_vpu_hantro_vc:
	@[ $(SOCFAMILY) != IMX ] && exit || \
	 $(call fbprint_b,"imx_vpu_hantro_vc") && \
	 cd $(MMDIR) && \
	 if [ ! -d imx_vpu_hantro_vc ]; then \
		 rm -rf imx_vpu_hantro_vc*; \
	     $(WGET) $(repo_vpu_hantro_vc_bin_url) -O vpu_hantro_vc.bin $(LOG_MUTE); \
		 [ $$? -ne 0 ] && { echo "Downloading $(repo_vpu_hantro_vc_bin_url) failed."; exit 1; } || \
	     chmod +x vpu_hantro_vc.bin; \
	     ./vpu_hantro_vc.bin --auto-accept --force $(LOG_MUTE) && \
	     mv imx-vpu-hantro-vc-* imx_vpu_hantro_vc && rm -f vpu_hantro_vc.bin; \
	 fi && \
	 cp -Prf $(MMDIR)/imx_vpu_hantro_vc/usr $(DESTDIR)/ && \
	 cp -Prf $(MMDIR)/imx_vpu_hantro_vc/unit_tests $(DESTDIR) && \
	 $(call fbprint_d,"imx_vpu_hantro_vc")

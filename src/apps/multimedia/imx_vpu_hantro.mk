# Copyright 2021-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# i.MX HANTRO VPU library for IMX8MM, IMX8MP, IMX8MQ

# RDEPEND: imx_vpu_hantro_daemon


imx_vpu_hantro:
	@[ $(DISTROVARIANT) != desktop -o $(SOCFAMILY) != IMX ] && exit || \
	 $(call fbprint_b,"imx_vpu_hantro") && \
	 cd $(MMDIR) && \
	 if [ ! -d imx_vpu_hantro ]; then \
	     wget -q $(repo_vpu_hantro_bin_url) -O vpu_hantro.bin && chmod +x vpu_hantro.bin && \
	     ./vpu_hantro.bin --auto-accept && \
	     mv imx-vpu-hantro-* imx_vpu_hantro && rm -f vpu_hantro.bin; \
	 fi && \
	 \
	 if [ ! -f $(DESTDIR)/usr/include/linux/dma-buf-imx.h ]; then \
	     bld linux-headers -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 cd imx_vpu_hantro && \
	 sed -i 's/\/imx//' Makefile_G1G2 Makefile_H1 && \
	 sed -i 's/dma-buf.h/dma-buf-imx.h/' decoder_sw/software/linux/dwl/dwl_linux.c \
	     h1_encoder/software/linux_reference/ewl/ewl_x280_common.c && \
	 ln -sf dma-buf.h $(DESTDIR)/usr/include/linux/dma-buf-imx.h && \
	 DEST_DIR=$(DESTDIR) CROSS_COMPILE=aarch64-linux-gnu- \
	 PLATFORM=IMX8MM ARCH="-march=armv8-a+crc+crypto" SDKTARGETSYSROOT=$(DESTDIR) \
	 $(MAKE) all && \
	 $(MAKE) install PLATFORM=IMX8MM DEST_DIR=$(DESTDIR) libdir=/usr/lib && \
	 $(call fbprint_d,"imx_vpu_hantro")

# Copyright 2021-2024,2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# i.MX HANTRO VPU library for IMX8MM, IMX8MP, IMX8MQ

# RDEPEND: imx_vpu_hantro_daemon


imx_vpu_hantro: $(KHEADER_FILE)
	@$(call dl_by_wget,vpu_hantro_bin,vpu_hantro.bin)
	cd $(MMDIR)
	if [ ! -d "$(MMDIR)"/imx_vpu_hantro ]; then
		chmod +x $(FBDIR)/dl/vpu_hantro.bin
		$(FBDIR)/dl/vpu_hantro.bin --auto-accept --force $(LOG_MUTE)
		mv $(basename $(notdir $(repo_vpu_hantro_bin_url))) imx_vpu_hantro
	fi
	$(call fbprint_b,"imx_vpu_hantro")
	cd imx_vpu_hantro
	sed -i 's/\/imx//' Makefile_G1G2 Makefile_H1
	sed -i 's/dma-buf.h/dma-buf-imx.h/' decoder_sw/software/linux/dwl/dwl_linux.c \
	     h1_encoder/software/linux_reference/ewl/ewl_x280_common.c
	ln -sf dma-buf.h $(DESTDIR)/usr/include/linux/dma-buf-imx.h
	mkdir -p $(RFSDIR)/usr/include
	cp -af $(DESTDIR)/usr/include/linux $(RFSDIR)/usr/include/
	DEST_DIR=$(DESTDIR) CROSS_COMPILE=aarch64-linux-gnu- \
	PLATFORM=IMX8MM ARCH="-march=armv8-a+crc+crypto" SDKTARGETSYSROOT=$(RFSDIR) \
	$(MAKE) all -j1 $(LOG_MUTE)
	$(MAKE) install PLATFORM=IMX8MM DEST_DIR=$(DESTDIR) libdir=/usr/lib $(LOG_MUTE)
	$(call fbprint_d,"imx_vpu_hantro")

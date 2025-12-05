# Copyright 2017-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# GPU driver and demo test apps for Vivante GPU on i.MX and LS1028a platforms


mali_imx:
	@[[ ! $(MACHINE) == *"imx95"* ]] && exit 0 || \
	$(call fbprint_b,"mali_imx ") && \
	mkdir -p $(GRAPHICSDIR) && cd $(GRAPHICSDIR) && \
	$(call dl_by_wget,mali_imx_bin,mali_imx.bin) && \
	if [ ! -d $(GRAPHICSDIR)/mali_imx ]; then \
		chmod a+x $(FBDIR)/dl/mali_imx.bin; \
		$(FBDIR)/dl/mali_imx.bin --auto-accept --force $(LOG_MUTE); \
		mv mali-imx-* mali_imx && rm -f mali_imx.bin; \
	fi && \
	cd $(GRAPHICSDIR)/mali_imx && \
	mkdir -p $(DESTDIR)/etc $(DESTDIR)/usr $(RFSDIR)/usr && \
	cp -af ./etc/* $(DESTDIR)/etc/ && \
	cp -af ./usr/* $(DESTDIR)/usr/ && \
	rsync -a ./usr/ $(RFSDIR)/usr/ && \
	sudo rm -f $(RFSDIR)/usr/lib/aarch64-linux-gnu/{libGLESv2.so,libGLESv2.so.2,libgbm.so.1,libvulkan.so,libvulkan.so.1,libEGL.so,libEGL.so.1} && \
	$(call fbprint_d,"mali_imx")

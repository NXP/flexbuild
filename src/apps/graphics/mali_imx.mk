# Copyright 2017-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# GPU driver and demo test apps for Vivante GPU on i.MX and LS1028a platforms


mali_imx:
	@[[ ! $(MACHINE) == *"imx95"* ]] && exit 0 || \
	 $(call fbprint_b,"mali_imx ") && \
	 mkdir -p $(GRAPHICSDIR) && cd $(GRAPHICSDIR) && \
	 if [ ! -d $(GRAPHICSDIR)/mali_imx ]; then \
	     echo Downloading $(repo_mali_imx_bin_url) $(LOG_MUTE) && \
		 rm -f mali_imx.bin && \
		 retry=0; success=0; \
		 while [ $${retry} -lt 3 ]; do \
			wget -q $(repo_mali_imx_bin_url) -O mali_imx.bin $(LOG_MUTE) && success=1 && break; \
			retry=$$((retry+1)); \
			echo "Download failed, retry $$retry/3 ..." $(LOG_MUTE); \
		 done; \
		 if [ $$success -ne 1 ]; then \
			echo "Download failed after 3 attempts, exiting."; \
			exit 1; \
		 fi && \
		 chmod a+x mali_imx.bin && \
	     ./mali_imx.bin --auto-accept $(LOG_MUTE) && mv mali-imx-* mali_imx && rm -f mali_imx.bin; \
	 fi && \
	 cd $(GRAPHICSDIR)/mali_imx && \
	 mkdir -p $(DESTDIR)/etc && mkdir -p $(DESTDIR)/usr && \
	 cp -af ./etc/* $(DESTDIR)/etc/ && \
	 cp -af ./usr/* $(DESTDIR)/usr/ && \
	 sudo rm -f $(RFSDIR)/usr/lib/aarch64-linux-gnu/{libGLESv2.so,libGLESv2.so.2,libgbm.so.1,libvulkan.so,libvulkan.so.1,libEGL.so,libEGL.so.1} && \
	 $(call fbprint_d,"mali_imx")

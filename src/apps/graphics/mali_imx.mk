# Copyright 2017-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# GPU driver and demo test apps for Vivante GPU on i.MX and LS1028a platforms


mali_imx:
	@[[ ! $(MACHINE) == *"imx95"* ]] && exit 0 || \
	 $(call fbprint_b,"mali_imx ") && \
	 if [ ! -d $(GRAPHICSDIR)/mali_imx ]; then \
	     mkdir -p $(GRAPHICSDIR) && cd $(GRAPHICSDIR) && \
	     echo Downloading $(repo_mali_imx_bin_url) $(LOG_MUTE) && \
	     wget -q $(repo_mali_imx_bin_url) -O mali_imx.bin $(LOG_MUTE) && chmod +x mali_imx.bin && \
	     ./mali_imx.bin --auto-accept $(LOG_MUTE) && mv imx-gpu-* mali_imx && rm -f mali_imx.bin; \
	 fi && \
	 cd $(GRAPHICSDIR)/mali_imx && \
	 cp -rfa gpu-core/* $(DESTDIR) && \
	 ln -sf libvulkan_VSI.so $(DESTDIR)/usr/lib/libvulkan.so.1 && \
         ln -sf libvulkan.so.1 $(DESTDIR)/usr/lib/libvulkan.so && \
	 rm -f $(DESTDIR)/usr/lib/libGL.so* && \
	 sudo rm -f $(RFSDIR)/usr/lib/aarch64-linux-gnu/{libGLESv2.so,libGLESv2.so.2,libgbm.so.1,libvulkan.so,libvulkan.so.1,libEGL.so,libEGL.so.1} && \
	 if [ -d gpu-tools ]; then cp -rfa gpu-tools/gmem-info/usr $(DESTDIR); fi && \
	 if [ -d gpu-demos ]; then cp -rf gpu-demos/opt $(DESTDIR); fi && \
	 cp -af $(DESTDIR)/usr/lib/libVSC.so $(RFSDIR)/usr/lib/ && \
	 cp -af $(DESTDIR)/usr/lib/libGLESv2.so* $(RFSDIR)/usr/lib/ && \
	 cp -af $(DESTDIR)/usr/lib/libOpenCL.so* $(RFSDIR)/usr/lib/ && \
	 cp -af $(DESTDIR)/usr/lib/libSPIRV_viv.so $(RFSDIR)/usr/lib/ && \
	 $(call fbprint_d,"mali_imx")

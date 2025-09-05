# Copyright 2017-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# GPU driver and demo test apps for Vivante GPU on i.MX and LS1028a platforms


gpu_viv:
	@[ $${MACHINE:0:4} != imx8 -a $${MACHINE:0:7} != ls1028a -o \
	 $(DISTROVARIANT) = base -o $(DISTROVARIANT) = tiny ] && exit || \
	 $(call fbprint_b,"gpu_viv ") && \
	 mkdir -p $(GRAPHICSDIR) && cd $(GRAPHICSDIR) && \
	 if [ ! -d $(GRAPHICSDIR)/gpu_viv ]; then \
		 rm -rf gpu_viv*; \
	     echo Downloading $(repo_gpu_viv_bin_url) $(LOG_MUTE); \
	     $(WGET) $(repo_gpu_viv_bin_url) -O gpu_viv.bin $(LOG_MUTE); \
		 [ $$? -ne 0 ] && { echo "Downloading $(repo_gpu_viv_bin_url) failed."; exit 1; } || \
		 chmod +x gpu_viv.bin; \
	     ./gpu_viv.bin --auto-accept --force $(LOG_MUTE) && mv imx-gpu-* gpu_viv && rm -f gpu_viv.bin; \
	 fi && \
	 cd $(GRAPHICSDIR)/gpu_viv && \
	 cp -rfa gpu-core/* $(DESTDIR) && \
	 cp -rfa gpu-core/* $(RFSDIR) && \
	 ln -sf libvulkan_VSI.so $(DESTDIR)/usr/lib/libvulkan.so.1 && \
         ln -sf libvulkan.so.1 $(DESTDIR)/usr/lib/libvulkan.so && \
	 rm -f $(DESTDIR)/usr/lib/libGL.so* && \
	 sudo rm -f $(RFSDIR)/usr/lib/aarch64-linux-gnu/{libGLESv2.so,libGLESv2.so.2,libgbm.so.1,libvulkan.so,libvulkan.so.1,libEGL.so,libEGL.so.1} && \
	 if [ -d gpu-tools ]; then cp -rfa gpu-tools/gmem-info/usr $(DESTDIR); fi && \
	 if [ -d gpu-demos ]; then cp -rf gpu-demos/opt $(DESTDIR); fi && \
	 $(call fbprint_d,"gpu_viv")

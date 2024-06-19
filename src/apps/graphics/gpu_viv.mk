# Copyright 2017-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# GPU driver and demo test apps for Vivante GPU on i.MX and LS1028a platforms



gpu_viv:
	@[ $(DESTARCH) != arm64 -o $(DISTROVARIANT) != desktop -a $(MACHINE) != imx93evk ] && exit || \
	 echo Building gpu_viv ... && \
	 if [ ! -d $(GRAPHICSDIR)/gpu_viv ]; then \
	     mkdir -p $(GRAPHICSDIR) && cd $(GRAPHICSDIR) && \
	     echo Downloading $(repo_gpu_viv_bin_url) && \
	     wget -q $(repo_gpu_viv_bin_url) -O gpu_viv.bin && chmod +x gpu_viv.bin && \
	     ./gpu_viv.bin --auto-accept && mv imx-gpu-* gpu_viv && rm -f gpu_viv.bin; \
	 fi && \
	 cd $(GRAPHICSDIR)/gpu_viv && \
	 cp -rfa gpu-core/* $(DESTDIR) && \
	 ln -sf egl_wayland.pc $(DESTDIR)/usr/lib/pkgconfig/egl.pc && \
         ln -sf libvulkan_VSI.so $(DESTDIR)/usr/lib/libvulkan.so.1 && \
         ln -sf libvulkan.so.1 $(DESTDIR)/usr/lib/libvulkan.so && \
	 rm -f $(DESTDIR)/usr/lib/libGL.so* && \
	 sudo rm -f $(RFSDIR)/usr/lib/aarch64-linux-gnu/{libGLESv2.so,libGLESv2.so.2,libgbm.so.1,libvulkan.so,libvulkan.so.1,libEGL.so,libEGL.so.1} && \
	 cp -rfa gpu-tools/gmem-info/usr $(DESTDIR) && \
	 if [ -d gpu-demos ]; then cp -rf gpu-demos/opt $(DESTDIR); fi && \
	 $(call fbprint_d,"gpu_viv")

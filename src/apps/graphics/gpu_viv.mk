# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# GPU driver and demo apps for Vivante GPU on i.MX and LS1028a platforms



VXC_BINARY_REMOVALS = libNNGPUBinary-*.so libNNVXCBinary-*.so libOvx12VXCBinary-*.so

ifeq ($(MACHINE),imx8qmmek)
  VXC_BINARY_INSTALLS = libNNGPUBinary-evis.so libNNVXCBinary-evis.so libOvx12VXCBinary-evis.so
else ifeq ($(MACHINE),imx8qxpmek)
  VXC_BINARY_INSTALLS = libNNGPUBinary-lite.so
else ifeq ($(MACHINE),imx8mqevk)
  VXC_BINARY_INSTALLS = libNNGPUBinary-lite.so
else ifeq ($(MACHINE),imx8mnevk)
    VXC_BINARY_INSTALLS = libNNGPUBinary-ulite.so
else ifeq ($(MACHINE),imx8mmevk)
    VXC_BINARY_INSTALLS = 
else
    # default for imx8mpevk
    VXC_BINARY_INSTALLS = libNNGPUBinary-evis2.so libNNVXCBinary-evis2.so libOvx12VXCBinary-evis2.so libNNGPUBinary-ulite.so
endif


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
	 cp -rf gpu-core/* $(DESTDIR) && \
	 mv $(DESTDIR)/usr/lib/wayland/* $(DESTDIR)/usr/lib/ && \
	 rm -rf $(DESTDIR)/usr/lib/wayland && \
	 ln -sf egl_wayland.pc $(DESTDIR)/usr/lib/pkgconfig/egl.pc && \
         ln -sf libvulkan_VSI.so $(DESTDIR)/usr/lib/libvulkan.so.1 && \
         ln -sf libvulkan.so.1 $(DESTDIR)/usr/lib/libvulkan.so && \
	 for vxcbin in $(VXC_BINARY_REMOVALS); do rm -f $(DESTDIR)/usr/lib/$$vxcbin; done && \
	 for vxcbin in $(VXC_BINARY_INSTALLS); do cp -f gpu-core/usr/lib/$$vxcbin $(DESTDIR)/usr/lib; done && \
	 rm -f $(DESTDIR)/usr/lib/libGL.so* && \
	 sudo rm -f $(RFSDIR)/usr/lib/aarch64-linux-gnu/libvulkan.so.1 && \
	 cp -rf gpu-tools/gmem-info/usr $(DESTDIR) && \
	 if [ -d gpu-demos ]; then cp -rf gpu-demos/opt $(DESTDIR); fi && \
	 $(call fbprint_d,"gpu_viv")

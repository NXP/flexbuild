# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



gpulib:
ifeq ($(CONFIG_GPULIB), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) != desktop ] && exit || echo Building gpulib ... && \
	 if [ ! -d $(GRAPHICSDIR)/gpulib ]; then \
	     mkdir -p $(GRAPHICSDIR) && cd $(GRAPHICSDIR) && \
	     echo Downloading $(repo_gpulib_bin_url) && \
	     wget -q $(repo_gpulib_bin_url) -O gpulib.bin && chmod +x gpulib.bin && \
	     ./gpulib.bin --auto-accept && mv imx-gpu-* gpulib && rm -f gpulib.bin; \
	 fi && \
	 cd $(GRAPHICSDIR)/gpulib && \
	 cp -rf gpu-core/* $(DESTDIR) && \
	 mv $(DESTDIR)/usr/lib/wayland/* $(DESTDIR)/usr/lib/ && \
	 rm -rf $(DESTDIR)/usr/lib/wayland && \
	 ln -sf egl_wayland.pc $(DESTDIR)/usr/lib/pkgconfig/egl.pc && \
	 ln -sf libvulkan.so.1.1.6 $(DESTDIR)/usr/lib/libvulkan.so && \
	 install -d $(DESTDIR)/etc/OpenCL/vendors && \
	 install -m 0644 gpu-core/etc/Vivante.icd $(DESTDIR)/etc/OpenCL/vendors/Vivante.icd && \
	 rm -f $(DESTDIR)/usr/include/GLES3/gl32.h && \
	 cp -rf gpu-tools/gmem-info/usr $(DESTDIR) && \
	 if [ -d gpu-demos ]; then cp -rf gpu-demos/opt $(DESTDIR); fi && \
	 $(call fbprint_d,"gpulib")
endif
endif

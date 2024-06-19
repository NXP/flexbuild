# Copyright 2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# Tools for tracing OpenGL, Direct3D, and other graphics APIs
# http://apitrace.github.io

# DEPEND: libwaffle-dev procps zlib1g-dev libpng-dev


apitrace:
ifeq ($(CONFIG_APITRACE),y)
	@[ $(DISTROVARIANT) != desktop ] && exit || \
	 $(call fbprint_b,"apitrace") && \
	 $(call repo-mngr,fetch,apitrace,apps/graphics) && \
	 cd $(GRAPHICSDIR)/apitrace && \
	 if [ ! -f .patchdone ]; then \
	     git am $(FBDIR)/patch/apitrace/*.patch && touch .patchdone; \
	 fi && \
	 cp -f $(FBDIR)/patch/apitrace/libproc2.pc $(DESTDIR)/usr/lib/pkgconfig && \
	 export CC="$(CROSS_COMPILE)gcc -march=armv8-a+crc+crypto -mbranch-protection=standard --sysroot=$(RFSDIR)" && \
	 export CXX="$(CROSS_COMPILE)g++ -march=armv8-a+crc+crypto -mbranch-protection=standard --sysroot=$(RFSDIR)" && \
	 export PKG_CONFIG_SYSROOT_DIR=$(RFSDIR) && \
	 export PKG_CONFIG_PATH=$(RFSDIR)/usr/lib/aarch64-linux-gnu/pkgconfig:$(RFSDIR)/usr/share/pkgconfig:$(DESTDIR)/usr/lib/pkgconfig && \
	 mkdir -p build_$(DISTROTYPE)_$(ARCH) && \
	 cmake  -S $(GRAPHICSDIR)/apitrace \
		-B $(GRAPHICSDIR)/apitrace/build_$(DISTROTYPE)_$(ARCH) \
		-DCMAKE_INSTALL_PREFIX:PATH=/usr \
		-DCMAKE_INSTALL_LIBDIR:PATH=lib \
		-DPython3_ROOT_DIR=/usr/bin \
		-DENABLE_STATIC_LIBGCC=OFF \
		-DENABLE_STATIC_LIBSTDCXX=OFF \
		-DENABLE_EGL=ON \
		-DENABLE_GUI=OFF \
		-DENABLE_MULTIARCH=OFF \
		-DENABLE_VIVANTE=ON \
		-DENABLE_WAFFLE=ON \
		-DENABLE_X11=OFF \
		-DVivante_INC_SEARCH_PATH=$(RFSDIR)/usr/include \
		-DVivante_LIB_SEARCH_PATH=$(RFSDIR)/usr/lib \
		-DCMAKE_BUILD_TYPE=release && \
	 VERBOSE=1 cmake --build $(GRAPHICSDIR)/apitrace/build_$(DISTROTYPE)_$(ARCH) --target install && \
	 $(call fbprint_d,"apitrace")
endif

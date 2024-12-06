# Copyright 2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# Cogl is a small open source library for using 3D graphics hardware for rendering.
# https://gitlab.gnome.org/GNOME/cogl

# clutter-1.0 depends on cogl-1.0

cogl:
	@[ $(DESTARCH) != arm64 -o $(DISTROVARIANT) != desktop ] && exit || \
	 $(call fbprint_b,"cogl") && \
	 $(call repo-mngr,fetch,cogl,apps/graphics) && \
	 cd $(GRAPHICSDIR)/cogl && \
	 if [ ! -f $(DESTDIR)/usr/lib/libGLESv2.so ]; then \
	     bld gpu_viv -r $(DISTROTYPE):$(DISTROVARIANT); \
	 fi && \
	 if [ ! -f .patchdone ]; then \
	    git am $(FBDIR)/patch/cogl/*.patch && touch .patchdone; \
	 fi && \
	 export CROSS=$(CROSS_COMPILE) && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)  \
		 -march=armv8-a+crc+crypto -mbranch-protection=standard -O2 \
		 -fstack-protector-strong -D_FORTIFY_SOURCE=2 -Wformat \
		 -Wformat-security -Werror=format-security -Wno-error=maybe-uninitialized" && \
	 export CFLAGS="-I$(DESTDIR)/usr/include/libdrm -I$(DESTDIR)/usr/include -I$(RFSDIR)/usr/include" && \
	 export LDFLAGS="-L$(DESTDIR)/usr/lib -L$(RFSDIR)/usr/lib/aarch64-linux-gnu" && \
	 sudo cp $(DESTDIR)/usr/lib/{libVSC.so,libgbm_viv.so,libGLESv2.so*} $(RFSDIR)/usr/lib && \
	 \
	 ./autogen.sh --prefix=/usr --host=aarch64-linux-gnu && \
	 ./configure CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" \
	 	--host=aarch64-linux-gnu \
		--prefix=/usr \
		--disable-silent-rules \
		--disable-dependency-tracking \
		--with-libtool-sysroot=$(RFSDIR) \
		--disable-introspection \
		--disable-gtk-doc \
		--enable-examples-install \
		--enable-cogl-pango \
		--enable-kms-egl-platform \
		--disable-null-egl-platform \
		--enable-wayland-egl-platform \
		--disable-xlib-egl-platform \
		--disable-gles1 \
		--disable-cairo \
		--disable-static \
		--enable-gles2 \
		--enable-gl \
		--enable-glx \
		--enable-wayland-egl-server \
		--enable-nls && \
	 $(MAKE) -j$(JOBS) && \
	 $(MAKE) install && \
	 $(call fbprint_d,"cogl")

# Copyright 2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# Cogl is a small open source library for using 3D graphics hardware for rendering.
# https://gitlab.gnome.org/GNOME/cogl

# clutter-1.0 depends on cogl-1.0

ifeq ($(filter imx95%,$(MACHINE)),$(MACHINE))
  DEP_COGL = mali_imx
  DEP_COGL_LDFLAGS = -lmali -lEGL -lGLESv2 -lgbm
else
  DEP_COGL = gpu_viv
  DEP_COGL_LDFLAGS = -lGAL -lVSC -lGLESv2 -lgbm_viv
endif

#cogl:
cogl: $(DEP_COGL)
	@[ $${MACHINE:0:4} != imx8 -a $${MACHINE:0:5} != imx95 ] && exit || \
	 $(call download_repo,cogl,apps/graphics,submod) && \
	 $(call patch_apply,cogl,apps/graphics) && \
	 $(call fbprint_b,"cogl") && \
	 cd $(GRAPHICSDIR)/cogl && \
	 export CROSS=$(CROSS_COMPILE) && \
	 export CC="$(CROSS_COMPILE)gcc" && \
	 export CFLAGS="--sysroot=$(RFSDIR) \
		-march=armv8-a+crc+crypto -mbranch-protection=standard -O2 \
		-fstack-protector-strong -D_FORTIFY_SOURCE=2 -Wformat \
		-Wformat-security -Werror=format-security -Wno-error=maybe-uninitialized \
		-I$(DESTDIR)/usr/include/libdrm -I$(DESTDIR)/usr/include -I$(RFSDIR)/usr/include" && \
	 export LDFLAGS="--sysroot=$(RFSDIR) -L$(DESTDIR)/usr/lib -L$(RFSDIR)/usr/lib/aarch64-linux-gnu $(DEP_COGL_LDFLAGS)" && \
	 \
	 [ -f Makefile ] && $(MAKE) distclean &>/dev/null || true && \
	 ./autogen.sh --prefix=/usr --host=aarch64-linux-gnu $(LOG_MUTE) && \
	 ./configure CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" \
	 	--host=aarch64-linux-gnu \
		--build=x86_64-linux-gnu \
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
		--enable-nls $(LOG_MUTE) && \
	 $(MAKE) -j$(JOBS) $(LOG_MUTE) && \
	 $(MAKE) install $(LOG_MUTE) && \
	 $(call fbprint_d,"cogl")

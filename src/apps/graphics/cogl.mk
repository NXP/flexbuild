# Copyright 2023,2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# Cogl is a small open source library for using 3D graphics hardware for rendering.
# https://gitlab.gnome.org/GNOME/cogl

# clutter-1.0 depends on cogl-1.0

ifeq ($(CONFIG_SOC_IMX95),y)
  DEP_COGL = mali_imx
  DEP_COGL_LDFLAGS = -lmali -lEGL -lGLESv2 -lgbm
else
  DEP_COGL = gpu_viv
  DEP_COGL_LDFLAGS = -lGAL -lVSC -lGLESv2 -lgbm_viv
endif


COGL_SRCDIR := $(GRAPHICSDIR)/cogl
COGL_SNAME := $(if $(CONFIG_SOC_IMX95),imx95,imx8)
COGL_BUILDDIR := $(COGL_SRCDIR)/build/cogl-$(COGL_SNAME)


#cogl:
cogl: $(DEP_COGL) libdrm wayland_protocols
	@$(call download_repo,cogl,apps/graphics,submod)
	 $(call patch_apply,cogl,apps/graphics)
	 $(call fbprint_b,"cogl")
	 mkdir -p $(COGL_BUILDDIR)
	 cd $(COGL_BUILDDIR)
	 export CROSS=$(CROSS_COMPILE)
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)"
	 export CFLAGS="--sysroot=$(RFSDIR) \
		-march=armv8-a+crc+crypto -mbranch-protection=standard -O2 \
		-fstack-protector-strong -D_FORTIFY_SOURCE=2 -Wformat \
		-Wformat-security -Werror=format-security -Wno-error=maybe-uninitialized \
		-I$(DESTDIR)/usr/include/libdrm -I$(DESTDIR)/usr/include -I$(RFSDIR)/usr/include"
	 export LDFLAGS="--sysroot=$(RFSDIR) -L$(DESTDIR)/usr/lib -L$(RFSDIR)/usr/lib/aarch64-linux-gnu $(DEP_COGL_LDFLAGS)"
	 export PKG_CONFIG_SYSROOT_DIR=$(RFSDIR)
	 export PKG_CONFIG_LIBDIR=$(RFSDIR)/usr/lib/pkgconfig:$(RFSDIR)/usr/lib/aarch64-linux-gnu/pkgconfig
	 $(COGL_SRCDIR)/autogen.sh --prefix=/usr --host=aarch64-linux-gnu $(LOG_MUTE)
	 $(COGL_SRCDIR)/configure \
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
		--enable-wayland-egl-server \
		--enable-nls $(LOG_MUTE)
	 $(MAKE) $(LOG_MUTE)
	 $(MAKE) install $(LOG_MUTE)
	 $(call fbprint_d,"cogl")

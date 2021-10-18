# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

libdrm:
ifeq ($(CONFIG_LIBDRM), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) != desktop ] && exit || \
	 $(call fbprint_b,"libdrm") && $(call repo-mngr,fetch,libdrm,apps/graphics) && cd $(GRAPHICSDIR)/libdrm && \
	 rm -rf build && mkdir build && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@TARGET_ARCH@%aarch64%g' \
	     -e 's%@TARGET_CPU@%cortex-a72%g' -e 's%@TARGET_ENDIAN@%little%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     $(FBDIR)/src/misc/meson/cross-compilation.conf > build/cross-compilation.conf && \
	 PYTHONNOUSERSITE=y PKG_CONFIG_SYSROOT_DIR=$(RFSDIR) \
	 meson build --cross-file=build/cross-compilation.conf \
	       --prefix=/usr --default-library=shared --buildtype=release \
	       -Dvc4=false -Dfreedreno=false -Dvmwgfx=false -Dnouveau=false \
	       -Damdgpu=false -Dradeon=false -Dintel=false -Dc_link_args="-pthread" && \
	 PYTHONNOUSERSITE=y DESTDIR=$(DESTDIR) ninja -j$(JOBS) install -C build && \
	 $(call fbprint_d,"libdrm")
endif
endif

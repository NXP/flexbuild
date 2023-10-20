# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

libdrm:
	@[ $(DESTARCH) != arm64 -o $(DISTROVARIANT) != desktop -a $(MACHINE) != imx93evk ] && exit || \
	 $(call fbprint_b,"libdrm") && \
	 $(call repo-mngr,fetch,libdrm,apps/graphics) && \
	 cd $(GRAPHICSDIR)/libdrm && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     -e 's%@DESTDIR@%$(DESTDIR)%g' $(FBDIR)/src/misc/meson/meson.cross > meson.cross && \
	 PYTHONNOUSERSITE=y PKG_CONFIG_SYSROOT_DIR=$(RFSDIR) \
	 meson setup build_$(DISTROTYPE)_$(ARCH) \
		--cross-file=meson.cross \
		--prefix=/usr \
		--default-library=shared --buildtype=release \
		-Damdgpu=enabled \
		-Dcairo-tests=disabled \
		-Detnaviv=enabled \
		-Dexynos=disabled \
		-Dfreedreno=enabled \
		-Dfreedreno-kgsl=false \
		-Dinstall-test-programs=true \
		-Dintel=enabled \
		-Dman-pages=disabled \
		-Dnouveau=enabled \
		-Domap=enabled \
		-Dradeon=enabled \
		-Dtegra=disabled \
		-Dtests=true \
		-Dudev=false \
		-Dvalgrind=disabled \
		-Dvc4=enabled \
		-Dvivante=true \
		-Dvmwgfx=enabled \
		-Dc_link_args="-pthread" && \
	 PYTHONNOUSERSITE=y DESTDIR=$(DESTDIR) \
	 ninja -j$(JOBS) install -C build_$(DISTROTYPE)_$(ARCH) && \
	 $(call fbprint_d,"libdrm")

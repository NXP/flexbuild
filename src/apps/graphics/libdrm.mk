# Copyright 2017-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

libdrm:
	@[ $(SOCFAMILY) != IMX -a $${MACHINE:0:7} != ls1028a ] && exit || \
	 $(call download_repo,libdrm,apps/graphics) && \
	 $(call patch_apply,libdrm,apps/graphics) && \
	 $(call fbprint_b,"libdrm") && \
	 cd $(GRAPHICSDIR)/libdrm && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     -e 's%@DESTDIR@%$(DESTDIR)%g' $(FBDIR)/src/system/meson.cross > meson.cross && \
	 rm -rf build_$(DISTROTYPE)_$(ARCH) && \
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
		-Dc_link_args="-pthread" $(LOG_MUTE) && \
	 PYTHONNOUSERSITE=y DESTDIR=$(DESTDIR) \
	 ninja -j$(JOBS) install -C build_$(DISTROTYPE)_$(ARCH) $(LOG_MUTE) && \
	 $(call fbprint_d,"libdrm")

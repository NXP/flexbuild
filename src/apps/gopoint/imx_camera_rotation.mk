# Copyright 2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause






imx_camera_rotation:
	@$(call download_repo,imx_camera_rotation,apps/gopoint)
	$(call fbprint_b,"imx_camera_rotation")
	export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)"
	export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)"
	cd $(GPDIR)/imx_camera_rotation/demos
	make clean $(LOG_MUTE)
	ln -sfn opencv4/opencv2 $(RFSDIR)/usr/include/opencv2
	ln -sfn ../libgbm.so.1.0.0 $(RFSDIR)/usr/lib/aarch64-linux-gnu/libgbm.so.1.0.0
	ln -sfn blas/libblas.so.3.12.1     $(RFSDIR)/usr/lib/aarch64-linux-gnu/libblas.so.3
	ln -sfn lapack/liblapack.so.3.12.1 $(RFSDIR)/usr/lib/aarch64-linux-gnu/liblapack.so.3
	ln -sfn libproxy/libpxbackend-1.0.so $(RFSDIR)/usr/lib/aarch64-linux-gnu/libpxbackend-1.0.so
	ln -sfn /usr/aarch64-linux-gnu/lib/ld-linux-aarch64.so.1 /lib/ld-linux-aarch64.so.1
	cp -f $(DESTDIR)/usr/include/g2d.h $(RFSDIR)/usr/include
	cp -af $(DESTDIR)/usr/lib/libg2d* $(RFSDIR)/usr/lib
	cp -af $(DESTDIR)/usr/lib/libdrm.so* $(RFSDIR)/usr/lib
	CFLAGS="$$(PKG_CONFIG_SYSROOT_DIR=$(RFSDIR) pkg-config --cflags opencv4 wayland-client) -Wall -g" \
	CXXFLAGS="$$(PKG_CONFIG_SYSROOT_DIR=$(RFSDIR) pkg-config --cflags opencv4 wayland-client) -Wall -g" \
	LDFLAGS="-L$(RFSDIR)/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,$(RFSDIR)/usr/lib/aarch64-linux-gnu" \
	$(MAKE) $(LOG_MUTE)
	cd $(GPDIR)/imx_camera_rotation
	rm -rf build_debian_arm64
	cmake  -S $(GPDIR)/imx_camera_rotation \
		-B build_debian_arm64 \
		-D CMAKE_BUILD_TYPE=Release \
		-D CMAKE_EXPORT_COMPILE_COMMANDS=ON \
		-D CMAKE_SYSROOT="$(RFSDIR)" $(LOG_MUTE)
	cmake --build build_debian_arm64 $(LOG_MUTE)
	rm -f /lib/ld-linux-aarch64.so.1
	install -d $(DESTDIR)/$(GPNT_APPS_FOLDER)/scripts/multimedia/imx-camera-rotation/demos
	install -m 0755 $(GPDIR)/imx_camera_rotation/build_debian_arm64/camera_rotation \
		$(DESTDIR)/$(GPNT_APPS_FOLDER)/scripts/multimedia/imx-camera-rotation
	install -m 0755 $(GPDIR)/imx_camera_rotation/demos/imx-camera-rotation-g2d/imx-camera-rotation-g2d \
		$(DESTDIR)/$(GPNT_APPS_FOLDER)/scripts/multimedia/imx-camera-rotation/demos
	install -m 0755 $(GPDIR)/imx_camera_rotation/demos/imx-camera-rotation-opencv/imx-camera-rotation-opencv \
		$(DESTDIR)/$(GPNT_APPS_FOLDER)/scripts/multimedia/imx-camera-rotation/demos
	install -m 0755 $(GPDIR)/imx_camera_rotation/demos/imx-camera-rotation-opengl/imx-camera-rotation-opengl \
		$(DESTDIR)/$(GPNT_APPS_FOLDER)/scripts/multimedia/imx-camera-rotation/demos
	$(call fbprint_d,"imx_camera_rotation")

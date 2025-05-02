# Copyright 2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# Smart Fitness application on i.MX

# DEPENDS: glib-2.0 gstreamer1.0 nnstreamer cairo

GPNT_APPS_FOLDER = /opt/gopoint-apps

IMX_SMART_FITNESS_DIR = $(GPNT_APPS_FOLDER)/scripts/machine_learning/imx_smart_fitness

imx_smart_fitness: nnstreamer
	@[ $(SOCFAMILY) != IMX -o $(DISTROVARIANT) != desktop ] && exit || \
	 $(call repo-mngr,fetch,imx_smart_fitness,apps/gopoint) && \
	 if [ ! -f $(DESTDIR)/usr/lib/gstreamer-1.0/libnnstreamer.so ]; then \
	     bld nnstreamer -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 $(call fbprint_b,"imx_smart_fitness") && \
	 sudo cp -rf $(DESTDIR)//usr/include/nnstreamer $(RFSDIR)//usr/include && \
	 cd $(GPDIR)/imx_smart_fitness && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)" && \
	 export PKG_CONFIG_LIBDIR=$(RFSDIR)/usr/lib/aarch64-linux-gnu/pkgconfig && \
	 export PKG_CONFIG_PATH=$(RFSDIR)/usr/share/pkgconfig && \
	 mkdir -p build_$(DISTROTYPE)_$(ARCH) && \
	 cmake  -S $(GPDIR)/imx_smart_fitness \
		-B build_$(DISTROTYPE)_$(ARCH) \
		-DCMAKE_CXX_FLAGS="-I$(DESTDIR)/usr/include -I$(RFSDIR)/usr/include" \
		-DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
		-DLIBRARY_PATH=$(RFSDIR)/usr/lib/aarch64-linux-gnu \
		-DCMAKE_BUILD_TYPE=release $(LOG_MUTE) && \
	 cmake --build build_$(DISTROTYPE)_$(ARCH) -j$(JOBS) --target all $(LOG_MUTE) && \
	 cmake --install build_$(DISTROTYPE)_$(ARCH) --prefix /usr $(LOG_MUTE) && \
	 $(CROSS_COMPILE)strip --remove-section=.comment --remove-section=.note --strip-unneeded \
	 build_$(DISTROTYPE)_$(ARCH)/src/imx-smart-fitness && \
	 install -m 0755 build_$(DISTROTYPE)_$(ARCH)/src/imx-smart-fitness $(DESTDIR)/$(IMX_SMART_FITNESS_DIR) && \
	 $(call fbprint_d,"imx_smart_fitness")

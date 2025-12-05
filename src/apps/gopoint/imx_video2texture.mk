# Copyright 2025 NXP
#
# SPDX-License-Identifier: BSD-3-Clause





GPNT_APPS_FOLDER = /opt/gopoint-apps

imx_video2texture:
#imx_video2texture: gst_plugins_good
ifeq ($(CONFIG_IMX_VIDEO2TEXTURE),y)
	@[ $${MACHINE:0:5} != imx95 ] && exit || \
	$(call download_repo,imx_video2texture,apps/gopoint) && \
	$(call patch_apply,imx_video2texture,apps/gopoint) && \
	\
	$(call fbprint_b,"imx_video2texture") && \
	export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)" && \
	export PKG_CONFIG_SYSROOT_DIR="$(RFSDIR)" && \
	export CFLAGS="-O2 -I$(DESTDIR)/usr/include -I$(RFSDIR)/usr/include $(EXTRA_CFLAGS)" && \
	export LDFLAGS="-L$(DESTDIR)/usr/lib -L$(RFSDIR)/usr/lib -L$(RFSDIR)/usr/lib/aarch64-linux-gnu $(EXTRA_LDFLAGS)" && \
	export LD_LIBRARY_PATH="$(RFSDIR)/usr/lib/aarch64-linux-gnu/libproxy:$(RFSDIR)/usr/lib/aarch64-linux-gnu:$(RFSDIR)/lib/aarch64-linux-gnu:$(LD_LIBRARY_PATH)" && \
	cd $(GPDIR)/imx_video2texture && \
	rm -rf build && mkdir -p build && cd build && \
	ln -sf /usr/aarch64-linux-gnu/lib/ld-linux-aarch64.so.1 /lib/ld-linux-aarch64.so.1 && \
	cp $(DESTDIR)/usr/include/gstimxcommon.h $(RFSDIR)/usr/include && \
	cmake .. -G 'Ninja' -DCMAKE_MAKE_PROGRAM=ninja \
		-DCMAKE_INSTALL_PREFIX=/usr \
		-DCMAKE_INSTALL_LIBDIR:PATH=lib \
		-DCMAKE_INSTALL_INCLUDEDIR:PATH=include \
		-DCMAKE_INSTALL_DATAROOTDIR:PATH=share \
		-DCMAKE_INSTALL_BINDIR:PATH=bin \
		-DCMAKE_INSTALL_SBINDIR:PATH=sbin \
		-DCMAKE_INSTALL_LIBEXECDIR:PATH=libexec \
		-DCMAKE_INSTALL_SYSCONFDIR:PATH=/etc \
		-DCMAKE_INSTALL_SO_NO_EXE=0 \
		-DCMAKE_NO_SYSTEM_FROM_IMPORTED=1 \
		-DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=ON  \
		-DQT_HOST_PATH:PATH=$(RFSDIR)/usr \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_CXX_FLAGS="-include GLES2/gl2.h -include GLES2/gl2ext.h -DQT_OPENGL_ES_2" -DCMAKE_EXE_LINKER_FLAGS="-lGLESv2 -lEGL" \
		-DCMAKE_PREFIX_PATH=$(RFSDIR)/usr/lib/aarch64-linux-gnu/cmake/Qt6 \
		-DOPENGL_opengl_LIBRARY=$(RFSDIR)/usr/lib/aarch64-linux-gnu/libOpenGL.so \
		-Wno-dev $(LOG_MUTE) && \
	ninja -j $(JOBS) -C $(GPDIR)/imx_video2texture/build -v all $(LOG_MUTE) && \
	rm -rf /lib/ld-linux-aarch64.so.1 && \
	\
	$(call fbprint_d,"imx_video2texture")
endif

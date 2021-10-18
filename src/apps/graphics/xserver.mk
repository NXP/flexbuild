# Copyright 2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# customize xorg-server with Wayland + GLES for Ubuntu GNOME running on NXP platform with GPU graphics acceleration


xserver:
ifeq ($(CONFIG_XSERVER), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) != desktop ] && exit || \
	 $(call repo-mngr,fetch,xserver,apps/graphics) && \
	 $(call fbprint_b,"xserver") && \
	 if [ ! -d $(RFSDIR)/usr/lib/aarch64-linux-gnu ]; then \
	     bld -i mkrfs -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/libGLES_CL.so ]; then \
	     bld -c gpulib -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/libdrm.so ]; then \
	     bld -c libdrm -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/include/wayland-client.h ]; then \
	     bld -c wayland -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -d $(DESTDIR)/usr/share/wayland-protocols ]; then \
	     bld -c wayland_protocols -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 cd $(GRAPHICSDIR)/xserver && \
	 if [ ! -f .patchdone ]; then \
	     git am $(FBDIR)/src/apps/graphics/patch/xserver/*.patch && touch .patchdone; \
	 fi && \
	 if [ ! -d $(RFSDIR)/usr/share/wayland-protocols ]; then \
	     sudo cp -rf $(DESTDIR)/usr $(RFSDIR)/; \
	 fi && \
	 cp -f $(FBDIR)/src/apps/graphics/dri.pc $(DESTDIR)/usr/lib/pkgconfig/ && \
	 export CROSS=$(CROSS_COMPILE) && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)  \
		    -fstack-protector-strong -D_FORTIFY_SOURCE=2 -Wformat \
		    -Wformat-security -Werror=format-security" && \
	 export CFLAGS="-O2 -pipe -g -feliminate-unused-debug-types \
			-I$(DESTDIR)/usr/include/libdrm -I$(DESTDIR)/usr/include -I$(RFSDIR)/usr/include" && \
	 export LDFLAGS="-L$(DESTDIR)/usr/lib -L$(RFSDIR)/usr/lib/aarch64-linux-gnu" && \
	 export PKG_CONFIG_SYSROOT_DIR=$(RFSDIR) && \
	 export PKG_CONFIG_PATH="$(DESTDIR)/usr/lib/pkgconfig:$(DESTDIR)/usr/share/pkgconfig:$(RFSDIR)/usr/share/pkgconfig" && \
	 export PKG_CONFIG_LIBDIR=$(RFSDIR)/usr/share/pkgconfig:$(RFSDIR)/usr/lib/pkgconfig:$(RFSDIR)/usr/lib/aarch64-linux-gnu/pkgconfig && \
	 export DBUS_CFLAGS="-I$(RFSDIR)/usr/include/dbus-1.0 -I$(RFSDIR)/usr/lib/aarch64-linux-gnu/dbus-1.0/include" && \
	 export DBUS_LIBS="-ldbus-1" && \
	 export GLAMOR_CFLAGS="-DLINUX -DWL_EGL_PLATFORM -I$(DESTDIR)/usr/include/libdrm" && \
	 export XWAYLANDMODULES_CFLAGS="-DLINUX -DWL_EGL_PLATFORM -I$(DESTDIR)/usr/include/libdrm" && \
	 export LDFLAGS="-Wl,-O1 -Wl,--hash-style=gnu -Wl,--as-needed -Wl,-z,relro" && \
	 export DEFAULT_LIBRARY_PATH="/usr/lib" && \
	 ./autogen.sh --prefix=/usr --host=aarch64-linux-gnu && \
	 ./configure \
	   --prefix=/usr \
	   --host=aarch64-linux-gnu \
	   --with-fop=no \
	   --with-pic \
	   --disable-static \
	   --disable-record \
	   --disable-dmx \
	   --disable-xnest \
	   --enable-xvfb \
	   --enable-composite \
	   --without-dtrace \
	   --with-int10=x86emu \
	   --sysconfdir=/etc/X11 \
	   --localstatedir=/var \
	   --with-xkb-output=/var/lib/xkb \
	   --with-os-name=Linux \
	   --disable-glx && \
	 $(MAKE) -j$(JOBS) && \
	 $(MAKE) -j$(JOBS) install && \
	 $(CROSS_COMPILE)strip hw/xwayland/Xwayland && \
	 install -m 755 hw/xwayland/Xwayland $(DESTDIR)/usr/bin && \
	 sudo rm -f $(RFSDIR)/usr/share/xsessions/* && \
	 if ! grep -q COGL_DRIVER $(RFSDIR)/etc/environment; then \
	     echo -e "COGL_DRIVER=gles2\nCLUTTER_DRIVER=gles2" | sudo tee -a $(RFSDIR)/etc/environment 1>/dev/null; \
	 fi && \
	 install -d $(DESTDIR)/usr/lib/systemd/system && \
	 install -d $(DESTDIR)/etc/systemd/system/graphical.target.wants && \
	 install -m 0755 $(FBDIR)/src/apps/graphics/gpuconfig $(DESTDIR)/etc && \
	 install -m 0644 $(FBDIR)/src/apps/graphics/gpuconfig.service $(DESTDIR)/usr/lib/systemd/system && \
	 ln -sf /lib/systemd/system/gpuconfig.service $(DESTDIR)/etc/systemd/system/graphical.target.wants/gpuconfig.service && \
	 ln -sf /usr/lib/systemd/system/graphical.target $(DESTDIR)/etc/systemd/system/default.target && \
	 $(call fbprint_d,"xserver")
endif
endif

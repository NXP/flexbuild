# Copyright 2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# NNStreamer Examples on i.MX platforms

# NNStreamer Examples LICENSE: BSD-3-Clause

# DEPENDS:  glib-2.0 gstreamer1.0 nnstreamer


GPNT_APPS_FOLDER = /opt/gopoint-apps

IMX_NNSTREANER_DIR = $(GPNT_APPS_FOLDER)/scripts/machine_learning/nnstreamer

imx_nnstreamer_examples:
	@[ $(SOCFAMILY) != IMX -o $(DISTROVARIANT) = tiny -o $(DISTROVARIANT) = base \
	   -o $(DISTROVARIANT) = server ] && exit || \
	 $(call fbprint_b,"imx_nnstreamer_examples") && \
	 $(call repo-mngr,fetch,imx_nnstreamer_examples,apps/gopoint) && \
	 cd $(GPDIR)/imx_nnstreamer_examples && \
	 if [ -d $(FBDIR)/patch/imx_nnstreamer_examples ] && [ ! -f .patchdone ]; then \
	     git am $(FBDIR)/patch/imx_nnstreamer_examples/*.patch && touch .patchdone; \
	 fi && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)" && \
	 export CXXFLAGS="-I$(DESTDIR)/usr/include/ -L$(DESTDIR)/usr/lib -lgstreamer-1.0" && \
	 export CFLAGS="-I$(DESTDIR)/usr/include/ -L$(DESTDIR)/usr/lib -lgstreamer-1.0" && \
	 export PKG_CONFIG_LIBDIR=$(RFSDIR)/usr/lib/aarch64-linux-gnu/pkgconfig && \
	 export PKG_CONFIG_PATH=$(RFSDIR)/usr/share/pkgconfig:$(RFSDIR)/usr/lib/pkgconfig && \
	 rm -rf build_$(DISTROTYPE)_$(ARCH) && \
	 mkdir -p build_$(DISTROTYPE)_$(ARCH) && \
	 cmake  -S $(GPDIR)/imx_nnstreamer_examples \
		-B build_$(DISTROTYPE)_$(ARCH) \
		-DCMAKE_BUILD_TYPE=release $(LOG_MUTE) && \
	 cmake --build build_$(DISTROTYPE)_$(ARCH) -j$(JOBS) --target all $(LOG_MUTE) && \
	 cmake --install build_$(DISTROTYPE)_$(ARCH) --prefix /usr $(LOG_MUTE) && \
	 mkdir -p $(DESTDIR)/$(IMX_NNSTREANER_DIR) && \
	 cp -rf {LICENSE,SCR-*} $(DESTDIR)/$(IMX_NNSTREANER_DIR) && \
	 for EXAM in classification depth detection face mixed pose segmentation ; do \
		 mkdir -p $(DESTDIR)/$(IMX_NNSTREANER_DIR)/$${EXAM}; \
		 cp -rf build_$(DISTROTYPE)_$(ARCH)/$${EXAM}/* $(DESTDIR)/$(IMX_NNSTREANER_DIR)/$${EXAM}; \
	 done && \
	 $(call fbprint_d,"imx_nnstreamer_examples")

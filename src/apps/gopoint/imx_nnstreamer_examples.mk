# Copyright 2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# NNStreamer Examples on i.MX platforms

# NNStreamer Examples LICENSE: BSD-3-Clause

# DEPENDS:  glib-2.0 gstreamer1.0 nnstreamer


GPNT_APPS_FOLDER = /opt/gopoint-apps

IMX_NNSTREANER_DIR = $(GPNT_APPS_FOLDER)/scripts/machine_learning/nnstreamer


imx_nnstreamer_examples:
	@[ $(SOCFAMILY) != IMX -o $(DISTROVARIANT) = tiny -o $(DISTROVARIANT) = base ] && exit || \
	 $(call fbprint_b,"imx_nnstreamer_examples") && \
	 $(call repo-mngr,fetch,imx_nnstreamer_examples,apps/gopoint) && \
	 cd $(GPDIR)/imx_nnstreamer_examples && \
	 if [ -d $(FBDIR)/patch/imx_nnstreamer_examples ] && [ ! -f .patchdone ]; then \
	     git am $(FBDIR)/patch/imx_nnstreamer_examples/*.patch && touch .patchdone; \
	 fi && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)" && \
	 export PKG_CONFIG_LIBDIR=$(RFSDIR)/usr/lib/aarch64-linux-gnu/pkgconfig && \
	 export PKG_CONFIG_PATH=$(RFSDIR)/usr/share/pkgconfig && \
	 mkdir -p build_$(DISTROTYPE)_$(ARCH) && \
	 cmake  -S $(GPDIR)/imx_nnstreamer_examples \
		-B build_$(DISTROTYPE)_$(ARCH) \
		-DCMAKE_BUILD_TYPE=release && \
	 cmake --build build_$(DISTROTYPE)_$(ARCH) --target all && \
	 cmake --install build_$(DISTROTYPE)_$(ARCH) --prefix /usr && \
	 mkdir -p $(DESTDIR)/$(IMX_NNSTREANER_DIR)/{common,classification,detection,pose} && \
	 cp -r common/* $(DESTDIR)/$(IMX_NNSTREANER_DIR)/common/ && \
	 cp {LICENSE,SCR-1.3.txt} $(DESTDIR)/$(IMX_NNSTREANER_DIR) && \
	 cp classification/{README.md,*.sh} $(DESTDIR)/$(IMX_NNSTREANER_DIR)/classification && \
	 cp build_$(DISTROTYPE)_$(ARCH)/classification/example_classification_mobilenet_v1_tflite \
	    $(DESTDIR)/$(IMX_NNSTREANER_DIR)/classification && \
	 cp detection/{README.md,*.sh} $(DESTDIR)/$(IMX_NNSTREANER_DIR)/detection && \
	 cp pose/{README.md,example_pose_movenet_tflite.py} $(DESTDIR)/$(IMX_NNSTREANER_DIR)/pose && \
	 $(call fbprint_d,"imx_nnstreamer_examples")

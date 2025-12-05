# Copyright 2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# NNStreamer Examples on i.MX platforms

# NNStreamer Examples LICENSE: BSD-3-Clause

# DEPENDS:  glib-2.0 gstreamer1.0 nnstreamer


GPNT_APPS_FOLDER = /opt/gopoint-apps

IMX_NNSTREANER_DIR = $(GPNT_APPS_FOLDER)/scripts/machine_learning/nnstreamer

imx_nnstreamer_examples: gstreamer
	@[ $(SOCFAMILY) != IMX  ] && exit || \
	 $(call download_repo,imx_nnstreamer_examples,apps/gopoint) && \
	 $(call patch_apply,imx_nnstreamer_examples,apps/gopoint) && \
	 $(call fbprint_b,"imx_nnstreamer_examples") && \
	 cd $(GPDIR)/imx_nnstreamer_examples && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)" && \
	 export CXXFLAGS="-I$(DESTDIR)/usr/include/ -I$(DESTDIR)/usr/include/gstreamer-1.0 \
		-L$(DESTDIR)/usr/lib -lgstreamer-1.0" && \
	 export CFLAGS="-I$(DESTDIR)/usr/include/ -L$(DESTDIR)/usr/lib -lgstreamer-1.0" && \
	 export PKG_CONFIG_LIBDIR=$(RFSDIR)/usr/lib/aarch64-linux-gnu/pkgconfig:$(DESTDIR)/usr/lib/pkgconfig && \
	 export PKG_CONFIG_PATH=$(RFSDIR)/usr/share/pkgconfig:$(RFSDIR)/usr/lib/pkgconfig && \
	 export PKG_CONFIG_SYSROOT_DIR=$(RFSDIR) && \
	 rm -rf build_$(DISTROTYPE)_$(ARCH) && \
	 mkdir -p build_$(DISTROTYPE)_$(ARCH) && \
	 cmake  -S $(GPDIR)/imx_nnstreamer_examples \
		-B build_$(DISTROTYPE)_$(ARCH) \
		-DCMAKE_BUILD_TYPE=release $(LOG_MUTE) && \
	 cmake --build build_$(DISTROTYPE)_$(ARCH) -j$(JOBS) --target all $(LOG_MUTE) && \
	 cmake --install build_$(DISTROTYPE)_$(ARCH) --prefix /usr $(LOG_MUTE) && \
	 mkdir -p $(DESTDIR)/$(IMX_NNSTREANER_DIR) && \
	 cp -rf {LICENSE,SCR-*} $(DESTDIR)/$(IMX_NNSTREANER_DIR) && \
	 install -d 0755 $(DESTDIR)/$(IMX_NNSTREANER_DIR)/classification && \
	 install -d 0755 $(DESTDIR)/$(IMX_NNSTREANER_DIR)/classification_detection && \
	 install -d 0755 $(DESTDIR)/$(IMX_NNSTREANER_DIR)/detection && \
	 install -d 0755 $(DESTDIR)/$(IMX_NNSTREANER_DIR)/dual_classification && \
	 install -d 0755 $(DESTDIR)/$(IMX_NNSTREANER_DIR)/emotion_detection && \
	 install -d 0755 $(DESTDIR)/$(IMX_NNSTREANER_DIR)/face_detection && \
	 install -d 0755 $(DESTDIR)/$(IMX_NNSTREANER_DIR)/object_detection && \
	 install -d 0755 $(DESTDIR)/$(IMX_NNSTREANER_DIR)/pose && \
	 install -d 0755 $(DESTDIR)/$(IMX_NNSTREANER_DIR)/pose_estimation && \
	 install -d 0755 $(DESTDIR)/$(IMX_NNSTREANER_DIR)/pose_face && \
	 install -d 0755 $(DESTDIR)/$(IMX_NNSTREANER_DIR)/semantic_segmentation && \
	 cp -rf build_$(DISTROTYPE)_$(ARCH)/object-detection/* $(DESTDIR)/$(IMX_NNSTREANER_DIR)/object_detection/ && \
	 cp -rf build_$(DISTROTYPE)_$(ARCH)/pose-estimation/* $(DESTDIR)/$(IMX_NNSTREANER_DIR)/pose_estimation/ && \
	 cp -rf build_$(DISTROTYPE)_$(ARCH)/classification/* $(DESTDIR)/$(IMX_NNSTREANER_DIR)/classification/ && \
	 cp -rf build_$(DISTROTYPE)_$(ARCH)/mixed-demos/example_classification_and_detection_tflite $(DESTDIR)/$(IMX_NNSTREANER_DIR)/classification_detection/ && \
	 cp -rf build_$(DISTROTYPE)_$(ARCH)/mixed-demos/example_double_classification_tflite $(DESTDIR)/$(IMX_NNSTREANER_DIR)/dual_classification/ && \
	 cp -rf build_$(DISTROTYPE)_$(ARCH)/face-processing/example_face_detection_tflite $(DESTDIR)/$(IMX_NNSTREANER_DIR)/face_detection/ && \
	 cp -rf build_$(DISTROTYPE)_$(ARCH)/face-processing/example_emotion_classification_tflite $(DESTDIR)/$(IMX_NNSTREANER_DIR)/emotion_detection/ && \
	 cp -rf build_$(DISTROTYPE)_$(ARCH)/mixed-demos/example_face_and_pose_detection_tflite $(DESTDIR)/$(IMX_NNSTREANER_DIR)/pose_face/ && \
	 cp -rf build_$(DISTROTYPE)_$(ARCH)/semantic-segmentation/example_segmentation_deeplab_v3_tflite $(DESTDIR)/$(IMX_NNSTREANER_DIR)/semantic_segmentation/ && \
	 $(call fbprint_d,"imx_nnstreamer_examples")

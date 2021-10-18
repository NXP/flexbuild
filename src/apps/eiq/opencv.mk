# Copyright 2019-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



opencv: dependency
ifeq ($(CONFIG_OPENCV), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu ] && exit || \
	 $(call fbprint_b,"OpenCV") && \
	 $(call repo-mngr,fetch,opencv,apps/eiq) && \
	 $(call repo-mngr,fetch,armcl,apps/eiq) && \
	 mkdir -p $(eIQDIR)/opencv/build && \
	 cd $(eIQDIR)/opencv/build && \
	 mkdir -p $(eIQDESTDIR)/usr/local/OpenCV && \
	 export DESTDIR=$(eIQDESTDIR) && \
	 CXX=$(CROSS_COMPILE)g++ CC=$(CROSS_COMPILE)gcc \
	 export PKG_CONFIG_FOUND=TRUE && \
	 export PKG_CONFIG_LIBDIR=$(RFSDIR)/usr/lib/aarch64-linux-gnu/pkgconfig && \
	 export PKG_CONFIG_PATH=$(RFSDIR)/usr/share/pkgconfig && \
	 export PKG_CONFIG_EXECUTABLE=$(RFSDIR)/usr/bin/pkg-config && \
	 cmake .. -DCMAKE_TOOLCHAIN_FILE=$(eIQDIR)/opencv/platforms/linux/aarch64-gnu.toolchain.cmake \
		  -DCMAKE_BUILD_TYPE=Release -DBUILD_opencv_python2=OFF \
		  -DBUILD_opencv_python3=ON -DWITH_GTK=ON -DWITH_GTK_2_X=ON -DWITH_FFMPEG=ON \
		  -DCMAKE_SYSROOT=$(RFSDIR) -DZLIB_LIBRARY=$(RFSDIR)/lib/aarch64-linux-gnu/libz.so \
		  -DWITH_OPENCL=OFF -DBUILD_JASPER=ON -DINSTALL_TESTS=ON \
		  -DBUILD_EXAMPLES=ON -DBUILD_opencv_apps=ON \
		  -DPYTHON_DEFAULT_EXECUTABLE=/usr/bin/python3 \
		  -DPYTHON3_EXECUTABLE=/usr/bin/python3 -DCMAKE_INSTALL_PREFIX=/usr/local \
		  -DPYTHON3_INCLUDE_DIR=$(RFSDIR)/usr/include/python3.8 \
		  -DPYTHON3_LIBRARY=$(RFSDIR)/usr/lib/aarch64-linux-gnu/libpython3.8.so \
		  -DPYTHON3_NUMPY_INCLUDE_DIRS=$(RFSDIR)/usr/lib/python3/dist-packages/numpy/core/include \
		  -DPYTHON3_PKGDIR=/usr/local/lib -DENABLE_VFPV3=OFF -DENABLE_NEON=ON \
		  -DFFMPEG_INCLUDE_DIRS=$(RFSDIR)/usr/include/aarch64-linux-gnu \
		  -DOPENCV_EXTRA_CXX_FLAGS="-I$(RFSDIR)/usr/include/gtk-2.0 -I$(RFSDIR)/usr/include/cairo \
		   -I$(RFSDIR)/usr/lib/aarch64-linux-gnu/glib-2.0/include -I$(RFSDIR)/usr/include/pango-1.0 \
		   -I$(RFSDIR)/usr/lib/aarch64-linux-gnu/gtk-2.0/include -I$(RFSDIR)/usr/include/gdk-pixbuf-2.0 \
		   -I$(RFSDIR)/usr/include/glib-2.0 -I$(RFSDIR)/usr/include/harfbuzz \
		   -I$(RFSDIR)/usr/include/atk-1.0 -I$(RFSDIR)/usr/include/aarch64-linux-gnu \
		   -I$(eIQDIR)/armcl/include" && \
	 make -j$(JOBS) && make install && \
	 cp -f bin/* $(eIQDESTDIR)/usr/local/bin && \
	 cp -f ../samples/dnn/models.yml $(eIQDESTDIR)/usr/local/OpenCV/ && \
	 cp -r ../samples/data $(eIQDESTDIR)/usr/local/OpenCV && \
	 cd $(eIQDESTDIR)/usr/local/lib/python3.8/dist-packages/cv2/python-3.8 && \
	 mv cv2.cpython-38-x86_64-linux-gnu.so cv2.cpython-38-aarch64-linux-gnu.so && cd - && \
	 $(call fbprint_d,"OpenCV")
endif
endif

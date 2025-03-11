# Copyright 2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# Open Deep Learning Compiler Stack
# Apache TVM (incubating) is a compiler stack for deep learning systems. \
# It is designed to close the gap between the productivity-focused deep learning frameworks, \
# and the performance- and efficiency-focused hardware backends. TVM works with deep learning \
# frameworks to provide end to end compilation to different backends.
#
# TVM LICENSE = "Apache-2.0 & BSD-3-Clause"

# RDEPENDS: tim-vx python3-decorator python3-numpy python3-attr python3-psutil python3

# COMPATIBLE_MACHINE: imx8mp

PYTHON_SITEPACKAGES_DIR = "/usr/lib/python3.11/site-packages"

tvm:
	@[ $(SOCFAMILY) != IMX -o $(DISTROVARIANT) = tiny -o $(DISTROVARIANT) = base ] && exit || \
	 $(call fbprint_b,"tvm") && \
	 $(call repo-mngr,fetch,tvm,apps/ml) && \
	 if [ ! -f $(DESTDIR)/usr/lib/libtim-vx.so ]; then \
	     bld tim_vx -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 sudo cp $(DESTDIR)/usr/lib/libtim-vx.so $(RFSDIR)/usr/lib && \
	 cd $(MLDIR)/tvm && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)" && \
	 mkdir -p build_$(DISTROTYPE)_$(ARCH) && \
	 cmake  -S $(MLDIR)/tvm \
		-B $(MLDIR)/tvm/build_$(DISTROTYPE)_$(ARCH) \
		-DCMAKE_CXX_FLAGS="-I$(DESTDIR)/usr/include -I$(RFSDIR)/usr/include" \
		-DCMAKE_STRIP=strip \
		-DUSE_VSI_NPU=ON \
		-DUSE_VSI_NPU_RUNTIME=ON && \
	 cmake --build $(MLDIR)/tvm/build_$(DISTROTYPE)_$(ARCH) -j$(JOBS) --target all && \
	 cmake --install build_$(DISTROTYPE)_$(ARCH) --prefix /usr && \
	 cd $(MLDIR)/tvm/python && \
	 NO_FETCH_BUILD=1 STAGING_INCDIR=$(RFSDIR)/usr/include STAGING_LIBDIR=$(RFSDIR)/usr/lib \
	 python3 setup.py bdist_wheel --verbose --dist-dir $(MLDIR)/tvm/build_$(DISTROTYPE)_$(ARCH)/dist && \
	 pip3 install --ignore-installed --disable-pip-version-check -vvv -t $(DESTDIR)/$(PYTHON_SITEPACKAGES_DIR) \
	      --no-cache-dir --no-deps $(MLDIR)/tvm/build_$(DISTROTYPE)_$(ARCH)/dist/tvm-*linux*.whl && \
	 if [ -f $(DESTDIR)/$(PYTHON_SITEPACKAGES_DIR)/bin/tvmc ]; then \
	     mv $(DESTDIR)/$(PYTHON_SITEPACKAGES_DIR)/bin/tvmc $(DESTDIR)/usr/bin; \
	 fi && \
	 chmod 755 $(DESTDIR)/usr/lib/libtvm*.so && \
	 install -d $(DESTDIR)/usr/bin/tvm/examples $(DESTDIR)/usr/lib/pkgconfig $(DESTDIR)/usr/include/dlpack && \
	 install -m 0644 $(FBDIR)/src/system/pkgconfig/tvm_runtime.pc $(DESTDIR)/usr/lib/pkgconfig/tvm_runtime.pc && \
	 cp ../tests/python/contrib/test_vsi_npu/label_image.py $(DESTDIR)/usr/bin/tvm/examples && \
	 cp ../3rdparty/dlpack/include/dlpack/dlpack.h $(DESTDIR)/usr/include/dlpack/ && \
	 $(call fbprint_d,"tvm")

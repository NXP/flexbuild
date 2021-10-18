# Copyright 2019-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


armnn: dependency boost swig crosspyconfig
ifeq ($(CONFIG_ARMNN), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu ] && exit || \
	 $(call fbprint_b,"ArmNN") && \
	 $(call repo-mngr,fetch,armnn,apps/eiq) && \
	 $(call repo-mngr,fetch,armcl,apps/eiq) && \
	 $(call repo-mngr,fetch,onnx,apps/eiq) && \
	 $(call repo-mngr,fetch,armnntf,apps/eiq) && \
	 if [ ! -f $(eIQDESTDIR)/usr/local/lib/libprotobuf.so ]; then \
	     bld -c protobuf -r $(DISTROTYPE):$(DISTROSCALE) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -f $(eIQDIR)/caffe/build/src/caffe/proto/caffe.pb.cc ]; then \
	    bld -c caffe -r $(DISTROTYPE):$(DISTROSCALE) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -d $(eIQDIR)/tensorflow-protobuf/tensorflow/core ]; then \
	     make tensorflow-protobuf -f $(FBDIR)/src/apps/eiq/eiq.mk; \
	 fi && \
	 if [ ! -f $(eIQDIR)/flatbuffer/libflatbuffers.a ]; then \
	     bld -c flatbuffer -r $(DISTROTYPE):$(DISTROSCALE) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -f $(eIQDESTDIR)/usr/local/lib/libarm_compute.so ]; then \
	     bld -c armcl -r $(DISTROTYPE):$(DISTROSCALE) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -f $(eIQDIR)/onnx/onnx/onnx.pb.cc ]; then \
	     bld -c onnx -r $(DISTROTYPE):$(DISTROSCALE) -f $(CFGLISTYML); \
	 fi && \
	 \
	 cd $(eIQDIR)/armnn && \
	 git reset --hard && patch -p1 < $(FBDIR)/src/apps/eiq/patch/0001-fix-pyarmnn-cross-compile-issue.patch && \
	 sed -i '49c option(USE_CCACHE "USE_CCACHE" OFF)' cmake/GlobalConfig.cmake && \
	 mkdir -p build && cd build && \
	 install_dir=$(eIQDESTDIR)/usr/local/bin && \
	 export CXX=$(CROSS_COMPILE)g++ && \
	 export CC=$(CROSS_COMPILE)gcc && \
	 cmake .. -DBUILD_TESTS=1 \
		  -DBUILD_UNIT_TESTS=1 \
		  -DBUILD_SHARED_LIBS=ON \
		  -DBUILD_PYTHON_SRC=1 \
		  -DBUILD_PYTHON_WHL=1 \
		  -DSWIG_DIR=/usr/local/share/swig/4.0.0 \
		  -DSWIG_EXECUTABLE=/usr/bin/swig \
		  -DPYTHON_INCLUDE_DIR=$(RFSDIR)/usr/include/python3.8 \
		  -DPYTHON_LIBRARY=$(RFSDIR)/usr/lib/aarch64-linux-gnu/libpython3.8.so \
		  -DARMCOMPUTE_ROOT=$(eIQDIR)/armcl \
		  -DARMCOMPUTE_BUILD_DIR=$(eIQDIR)/armcl/build \
		  -DBOOST_ROOT=$(eIQDESTDIR)/usr/local \
		  -DTF_GENERATED_SOURCES=../../tensorflow-protobuf \
		  -DBUILD_TF_LITE_PARSER=1 \
		  -DTF_LITE_GENERATED_PATH=../../armnntf/tensorflow/lite/schema \
		  -DTF_LITE_SCHEMA_INCLUDE_PATH=../../armnntf/tensorflow/lite/schema \
		  -DFLATBUFFERS_ROOT=../../flatbuffer \
		  -DFLATBUFFERS_LIBRARY=../../flatbuffer/libflatbuffers.a \
		  -DFLATBUFFERS_INCLUDE_PATH=../../flatbuffer/include \
		  -DFLATC_DIR=../../flatbuffer_host \
		  -DARMCOMPUTENEON=1 \
		  -DBUILD_TF_PARSER=1 \
		  -DCAFFE_GENERATED_SOURCES=../../caffe/build/src \
		  -DBUILD_CAFFE_PARSER=1 \
		  -DPROTOBUF_ROOT=$(eIQDESTDIR)/usr/local \
		  -DPROTOBUF_LIBRARY_DEBUG=../../protobuf/arm64_build/src/.libs/libprotobuf.so \
		  -DPROTOBUF_LIBRARY_RELEASE=../../protobuf/arm64_build/src/.libs/libprotobuf.so \
		  -DBUILD_ONNX_PARSER=1 \
		  -DONNX_GENERATED_SOURCES=../../onnx \
		  -DCMAKE_INSTALL_PREFIX=/usr/local && \
	 make -j$(JOBS) && \
	 make install && \
	 cp_args="-Prf --preserve=mode,timestamps --no-preserve=ownership" && \
	 find tests -maxdepth 1 -type f -executable -exec cp $$cp_args {} $$install_dir \; && \
	 find . -name "lib*.so" | xargs -I {} cp {} $(eIQDESTDIR)/usr/local/lib && \
	 mkdir -p $(eIQDESTDIR)/usr/share/armnn && \
	 cp -rf $(eIQDIR)/armnn/python/pyarmnn/examples $(eIQDESTDIR)/usr/share/armnn/ && \
	 cp $(eIQDIR)/armnn/build/python/pyarmnn/dist/pyarmnn-*.whl $(eIQDESTDIR)/usr/share/armnn/ && \
	 mv $(eIQDESTDIR)/usr/share/armnn/pyarmnn-22.0.0-cp38-cp38-linux_x86_64.whl  \
	    $(eIQDESTDIR)/usr/share/armnn/pyarmnn-22.0.0-cp38-cp38-linux_aarch64.whl && \
	 cp $$cp_args UnitTests $$install_dir && ls -l $(eIQDESTDIR)/usr/local/{bin,lib}/*rmnn* && \
	 $(call fbprint_d,"ArmNN")
endif
endif

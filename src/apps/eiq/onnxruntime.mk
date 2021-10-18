# Copyright 2019-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



onnxruntime: dependency crosspyconfig
ifeq ($(CONFIG_ONNXRUNTIME), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu ] && exit || \
	 $(call fbprint_b,"onnxruntime") && \
	 $(call repo-mngr,fetch,onnxruntime,apps/eiq,nosubmodule) && \
	 cd $(eIQDIR)/onnxruntime && \
	 git submodule update --init && \
	 if [ ! -f $(HOME)/cmake-3.16.2/bin/cmake ]; then \
	     wget https://github.com/Kitware/CMake/releases/download/v3.16.2/cmake-3.16.2-Linux-x86_64.sh && \
	     chmod +x cmake-3.16.2-Linux-x86_64.sh && mkdir -p $(HOME)/cmake-3.16.2 && \
	     ./cmake-3.16.2-Linux-x86_64.sh --skip-license --prefix=$(HOME)/cmake-3.16.2; \
	 fi && \
	 if [ ! -f $(HOME)/protoc-3.6.1/bin/protoc ]; then \
	     mkdir -p $(HOME)/protoc-3.6.1 && cd $(HOME)/protoc-3.6.1 && \
	     wget https://github.com/protocolbuffers/protobuf/releases/download/v3.6.1/protoc-3.6.1-linux-x86_64.zip && \
	     unzip protoc-3.6.1-linux-x86_64.zip && sudo cp -rf include/google /usr/local/include/ && cd -; \
	 fi && \
	 echo "SET(CMAKE_SYSTEM_NAME Linux)" > tool.cmake && \
	 echo "set(CMAKE_SYSTEM_PROCESSOR aarch64)" >> tool.cmake && \
	 echo "set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)" >> tool.cmake && \
	 echo "set(CMAKE_C_COMPILER aarch64-linux-gnu-gcc)" >> tool.cmake && \
	 echo "SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)" >> tool.cmake && \
	 echo "SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)" >> tool.cmake && \
	 echo "SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)" >> tool.cmake && \
	 echo "SET(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)" >> tool.cmake && \
	 sed -i 's/.*linux_distribution.*/    return False/' tools/ci_build/build.py && \
	 ./build.sh --config RelWithDebInfo --arm64 --update --build --build_shared_lib --build_wheel --parallel \
		--cmake_path=$(HOME)/cmake-3.16.2/bin/cmake  \
		--path_to_protoc_exe=$(HOME)/protoc-3.6.1/bin/protoc \
		--cmake_extra_defines ONNXRUNTIME_VERSION=$(cat ./VERSION_NUMBER) \
		onnxruntime_USE_PREBUILT_PB=OFF \
		onnxruntime_BUILD_UNIT_TESTS=ON \
		CMAKE_TOOLCHAIN_FILE=$(eIQDIR)/onnxruntime/tool.cmake \
		CMAKE_CXX_FLAGS="-Wno-error=unused-parameter -Wno-error=deprecated-copy \
				 -I$(RFSDIR)/usr/aarch64-linux-gnu/include -I$(RFSDIR)/usr/include/python3.8" \
		CMAKE_NO_SYSTEM_FROM_IMPORTED=True \
		ZLIB_LIBRARY=$(RFSDIR)/lib/aarch64-linux-gnu/libz.so \
		PNG_LIBRARY=$(RFSDIR)/usr/lib/aarch64-linux-gnu/libpng.so \
		PYTHON_LIBRARY=$(RFSDIR)/usr/lib/aarch64-linux-gnu/libpython3.8.so \
		PYTHON_INCLUDE_DIR=$(RFSDIR)/usr/include/python3.8 && \
	 cp -f build/Linux/*/libonnxruntime*.a build/Linux/*/onnx/libonnx*.a $(eIQDESTDIR)/usr/local/lib && \
	 cp -f build/Linux/*/libonnxruntime.so $(eIQDESTDIR)/usr/local/lib && \
	 mkdir -p $(eIQDESTDIR)/usr/share/onnxruntime && \
	 cp -f build/Linux/*/dist/onnxruntime-*.whl $(eIQDESTDIR)/usr/share/onnxruntime/ && \
	 cp -f build/Linux/*/onnxruntime_perf_test build/Linux/*/onnx_test_runner $(eIQDESTDIR)/usr/local/bin/ && \
	 mv $(eIQDESTDIR)/usr/share/onnxruntime/onnxruntime-1.1.2-cp38-cp38-linux_x86_64.whl \
	    $(eIQDESTDIR)/usr/share/onnxruntime/onnxruntime-1.1.2-cp38-cp38-linux_aarch64.whl && \
	 $(call fbprint_d,"onnxruntime")
endif
endif

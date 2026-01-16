# Copyright 2022-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# TensorFlow Lite C++ Library
# Version: 2.16.2

# DEPEND: protobuf-compiler + libprotobuf-dev + libprotoc-dev for protoc on host
# libpython3.13-dev python3-pybind11 on target

# run ./benchmark_model --external_delegate_path=<patch_to_libvx_delegate.so> --graph=<tflite_model.tflite>


TFLITE_VERSION = tensorflow-lite-2.18.0

tflite: flatbuffers
	@[ $(SOCFAMILY) != IMX  ] && exit || \
	 $(call download_repo,tflite,apps/ml) && \
	 $(call patch_apply,tflite,apps/ml) && \
	 cd $(MLDIR)/tflite && \
	 if [ ! -f $(FBDIR)/dl/mobilenet.tgz ]; then \
		$(call dl_by_wget,model_mobv1,mobilenet.tgz); \
	 fi && \
	 if ! ls mobilenet_v1* >/dev/null 2>&1; then \
		 tar xf $(FBDIR)/dl/mobilenet.tgz; \
	 fi && \
	 $(call fbprint_b,"tensorflow-lite") && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)" && \
	 export CMAKE_TLS_VERIFY=0 && \
	 if [ -d "build_$(DISTROTYPE)_$(ARCH)" ]; then \
		cmake --build build_$(DISTROTYPE)_$(ARCH) --target clean; \
		cd build_$(DISTROTYPE)_$(ARCH);  \
		rm -rf CMakeCache.txt Makefile cmake_install.cmake compile_commands.json \
			CMakeFiles bin lib/*.so* lib/*.a \
			example_proto_generated examples/*.o \
			tools/*.o tmp/* ; \
		find . -type d -name "CMakeFiles" -exec rm -rf {} + ; \
		cd ..; \
	 fi && \
	 cmake  -S tensorflow/lite \
		-B build_$(DISTROTYPE)_$(ARCH) \
		-DFETCHCONTENT_BASE_DIR="$(MLDIR)/tflite/build_$(DISTROTYPE)_$(ARCH)/_deps" \
		-DCMAKE_POLICY_DEFAULT_CMP0169=OLD \
		-DCMAKE_POLICY_DEFAULT_CMP0177=OLD \
		-DCMAKE_BUILD_TYPE=release \
		-DCMAKE_SYSTEM_NAME=Linux \
		-DCMAKE_SYSTEM_PROCESSOR=aarch64 \
		-DTFLITE_ENABLE_FLATBUFFERS=ON \
		-DTFLITE_HOST_TOOLS_DIR=/usr/bin \
		-DFETCHCONTENT_FULLY_DISCONNECTED=OFF \
		-DTFLITE_EVAL_TOOLS=on \
		-DTFLITE_BUILD_SHARED_LIB=on \
		-DTFLITE_ENABLE_NNAPI=off \
		-DTFLITE_ENABLE_NNAPI_VERBOSE_VALIDATION=on \
		-DTFLITE_ENABLE_RUY=on \
		-DTFLITE_ENABLE_XNNPACK=on \
		-DTFLITE_PYTHON_WRAPPER_BUILD_CMAKE2=on \
		-DTFLITE_ENABLE_EXTERNAL_DELEGATE=on $(LOG_MUTE) && \
	 VERBOSE=0 cmake --build build_$(DISTROTYPE)_$(ARCH) -j$(JOBS) --target all -- benchmark_model label_image $(LOG_MUTE) && \
	 cd build_$(DISTROTYPE)_$(ARCH) && \
	 CI_BUILD_PYTHON=python3 BUILD_NUM_JOBS=$(JOBS) \
	 $(MLDIR)/tflite/tensorflow/lite/tools/pip_package/build_pip_package_with_cmake2.sh aarch64 $(LOG_MUTE) && \
	 $(CROSS_COMPILE)strip libtensorflow-lite.so* && \
	 cp -Pf libtensorflow-lite.so* $(DESTDIR)/usr/lib && \
	 install -d $(DESTDIR)/usr/include/tensorflow/lite && \
	 install -d $(DESTDIR)/usr/share/pkgconfig && \
	 install -d $(DESTDIR)/usr/include/tensorflow/core/public && \
	 install -d $(DESTDIR)/usr/include/tensorflow/core/platform && \
	 install -d $(DESTDIR)/usr/include/tsl/platform && \
	 install -d $(DESTDIR)/usr/lib/python3/dist-packages && \
	 cd $(MLDIR)/tflite/tensorflow/lite && \
	 find . -name "*.h" | xargs -I {} cp {} $(DESTDIR)/usr/include/tensorflow/lite && \
	 cp $(MLDIR)/tflite/tensorflow/core/public/version.h $(DESTDIR)/usr/include/tensorflow/core/public && \
	 rsync -avz $(MLDIR)/tflite/tensorflow/* $(DESTDIR)/usr/include/tensorflow/ $(LOG_MUTE) && \
	 cp $(FBDIR)/src/system/pkgconfig/tensorflow2-lite.pc $(DESTDIR)/usr/lib/pkgconfig && \
	 \
	 $(call fbprint_n,"install examples") && \
	 install -d $(DESTDIR)/usr/bin/$(TFLITE_VERSION)/examples && \
	 cd $(MLDIR)/tflite/build_$(DISTROTYPE)_$(ARCH) && \
	 $(CROSS_COMPILE)strip examples/label_image/label_image tools/benchmark/benchmark_model \
	     tools/evaluation/{coco_object_detection_run_eval,imagenet_image_classification_run_eval,inference_diff_run_eval} && \
	 install -m 0555 examples/label_image/label_image $(DESTDIR)/usr/bin/$(TFLITE_VERSION)/examples && \
	 install -m 0555 tools/benchmark/benchmark_model $(DESTDIR)/usr/bin/$(TFLITE_VERSION)/examples && \
	 install -m 0555 tools/evaluation/{coco_object_detection_run_eval,imagenet_image_classification_run_eval,inference_diff_run_eval} \
		 $(DESTDIR)/usr/bin/$(TFLITE_VERSION)/examples && \
	 \
	 $(call fbprint_n,"install label_image data") && \
	 cp $(MLDIR)/tflite/tensorflow/lite/examples/label_image/testdata/grace_hopper.bmp $(DESTDIR)/usr/bin/$(TFLITE_VERSION)/examples && \
	 cp $(MLDIR)/tflite/tensorflow/lite/java/ovic/src/testdata/labels.txt $(DESTDIR)/usr/bin/$(TFLITE_VERSION)/examples && \
	 \
	 $(call fbprint_n,"install mobilenet tflite file python example and pip package") && \
	 cp $(MLDIR)/tflite/mobilenet_*.tflite $(DESTDIR)/usr/bin/$(TFLITE_VERSION)/examples && \
	 cp $(MLDIR)/tflite/tensorflow/lite/examples/python/label_image.py $(DESTDIR)/usr/bin/$(TFLITE_VERSION)/examples && \
	 pip3 install --ignore-installed --disable-pip-version-check -vvv --platform linux_aarch64 -t $(DESTDIR)/usr/lib/python3/dist-packages \
		--no-cache-dir --upgrade --no-deps $(MLDIR)/tflite/build_$(DISTROTYPE)_$(ARCH)/tflite_pip/dist/tflite_runtime-*.whl $(LOG_MUTE) && \
	 #rm -rf $(DESTDIR)/usr/include/tensorflow/lite/{interpreter.h,util.h} && \
	 $(call fbprint_d,"tflite")

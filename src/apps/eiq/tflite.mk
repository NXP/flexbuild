# Copyright 2019-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



tflite: dependency swig crosspyconfig
ifeq ($(CONFIG_TFLITE), "y")
	@[ $(DISTROTYPE) != ubuntu ] && exit || \
	 if [ ! -d $(RFSDIR)/usr/lib ]; then \
	     echo building dependent $(RFSDIR) && \
	     bld -i mkrfs -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 $(call fbprint_b,"tflite $(repo_tflite_tag)") && \
	 $(call repo-mngr,fetch,tflite,apps/eiq) && \
	 cd $(eIQDIR)/tflite && \
	 if [ ! -f .patchdone ]; then \
	     patch -p1 < $(FBDIR)/src/apps/eiq/patch/0001-Fixed-dependency-download-script.patch && touch .patchdone; \
	 fi && \
	 sed -i 's/curl -Lo/wget -O/g' tensorflow/lite/tools/make/download_dependencies.sh && \
	 if [ $(DESTARCH) = arm64 -a ! -f tensorflow/lite/tools/make/gen/linux_aarch64/lib/libtensorflow-lite.a ]; then \
	     ./tensorflow/lite/tools/make/download_dependencies.sh && \
	     LDFLAGS=-L$(RFSDIR)/lib/aarch64-linux-gnu \
	     ./tensorflow/lite/tools/make/build_aarch64_lib.sh; \
	 elif [ $(DESTARCH) = arm32 -a ! -f tensorflow/lite/tools/make/gen/rpi_armv7l/lib/libtensorflow-lite.a ]; then \
	     ./tensorflow/lite/tools/make/download_dependencies.sh && \
	     ./tensorflow/lite/tools/make/build_rpi_lib.sh; \
	 fi && \
	 if [ $(DESTARCH) = arm64 -a ! -f tensorflow/lite/tools/pip_package/gen/tflite_pip/python3/dist/tflite_runtime*.whl ]; then \
	     export TENSORFLOW_TARGET=aarch64 && \
	     export PATH=$(FBDIR)/src/apps/eiq/swig/host_build/bin/:$(PATH) && \
	     LDFLAGS=-L$(eIQDIR)/tflite/tensorflow/lite/tools/make/gen/linux_aarch64/lib/ \
	     ./tensorflow/lite/tools/pip_package/build_pip_package.sh; \
	 fi && \
	 [ $(DESTARCH) = arm64 ] && tfarch=linux_aarch64 || tfarch=rpi_armv7l && \
	 cp -f tensorflow/lite/tools/make/gen/$$tfarch/bin/* $(eIQDESTDIR)/usr/local/bin && \
	 cp -f tensorflow/lite/tools/make/gen/$$tfarch/lib/*.a $(eIQDESTDIR)/usr/local/lib && \
	 mkdir -p $(eIQDESTDIR)/usr/share/tflite && \
	 mkdir -p $(eIQDESTDIR)/usr/share/tflite/examples && \
	 cp -f tensorflow/lite/examples/label_image/testdata/grace_hopper.bmp $(eIQDESTDIR)/usr/share/tflite/examples/ && \
	 cp -f tensorflow/lite/java/ovic/src/testdata/labels.txt $(eIQDESTDIR)/usr/share/tflite/examples/ && \
	 cp -f tensorflow/lite/examples/python/label_image.py $(eIQDESTDIR)/usr/share/tflite/examples/ && \
	 cp $(eIQDIR)/tflite/tensorflow/lite/tools/pip_package/gen/tflite_pip/python3/dist/tflite_runtime*.whl \
	 $(eIQDESTDIR)/usr/share/tflite/ && \
	 ls -l $(eIQDESTDIR)/usr/local/bin/benchmark_model $(eIQDESTDIR)/usr/local/bin/minimal && \
	 ls -l $(eIQDESTDIR)/usr/local/lib/libtensorflow-lite.a $(eIQDESTDIR)/usr/local/lib/benchmark-lib.a && \
	 $(call fbprint_d,"tflite")
endif

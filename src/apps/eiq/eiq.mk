#
# Copyright 2019-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
#
# NXP eIQ™ Machine Learning Software Development Environment
#

eIQ_REPO_LIST = opencv armcl boost protobuf flatbuffer caffe onnx onnxruntime \
		armnn tflite


eIQDIR = $(PKGDIR)/apps/eiq
eIQDESTDIR = $(DESTDIR)_eIQ

eiq: dependency $(eIQ_REPO_LIST) tensorflow-protobuf eiq_pack


CAFFE_DEPENDENT_PKG = libgflags-dev libgoogle-glog-dev liblmdb-dev libopenblas-dev \
		      libatlas-base-dev libleveldb-dev libsnappy-dev libopencv-dev \
		      libhdf5-serial-dev libboost-all-dev

TENSORFLOW_DEP_APT_PKG = python3-wheel python3-h5py
TENSORFLOW_DEP_PIP_PKG = enum34 mock keras_applications==1.0.8 keras_preprocessing==1.1.0
TARGET_DEPENDENT_PKG   = libhdf5-serial-dev python3-wheel python3-h5py scons libgtk2.0-dev pkg-config  \
		         libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libavresample-dev \
		         python3-pip


boost_url ?= https://telkomuniversity.dl.sourceforge.net/project/boost/boost/1.64.0/boost_1_64_0.tar.bz2


tensorflow-protobuf:
	@cd $(eIQDIR)/armnntf && \
	 echo building dependent tensorflow-protobuf && \
	 ../armnn/scripts/generate_tensorflow_protobuf.sh \
	 ../tensorflow-protobuf $(eIQDIR)/protobuf/host_build/usr/local && \
	 echo built tensorflow-protobuf in $(eIQDIR)/tensorflow-protobuf/tensorflow



swig:
	@if [ ! -d /usr/local/share/swig/4.0.0 ]; then \
	     $(call fbprint_b,"swig") && \
	     $(call repo-mngr,fetch,swig,apps/eiq) && \
	     if [ ! -f /usr/bin/pcre++-config ]; then \
		 sudo apt install -y libpcre++-dev; \
	     fi && \
	     if [ ! -f /usr/bin/swig ]; then \
		sudo apt install -y swig; \
	     fi && \
	     cd $(eIQDIR)/swig && mkdir -p host_build && \
	     ./autogen.sh && ./configure && \
	     make && sudo make install && \
	     $(call fbprint_d,"swig"); \
	 fi



boost: dependency
	@if [ ! -d $(eIQDESTDIR)/usr/local/include/boost ]; then \
	     $(call fbprint_b,"boost") && \
	     mkdir -p $(HOME)/.boost && cd $(HOME)/.boost && \
	     if [ ! -f boost_1_64_0.tar.bz2 ]; then \
		 wget $(boost_url) && tar xf boost_1_64_0.tar.bz2 --strip-components 1; \
	     fi && \
	     echo "using gcc : arm : $(CROSS_COMPILE)g++ ;" > user_config.jam && \
	     ./bootstrap.sh --prefix=$(eIQDESTDIR)/usr/local && \
	     ./b2 install -j$(JOBS) toolset=gcc-arm link=static cxxflags=-fPIC \
	     --with-filesystem --with-test --with-log \
	     --with-program_options --user-config=user_config.jam && \
	     $(call fbprint_d,"boost"); \
	 fi




dependency:
	@export PATH="$(PATH):$(HOME)/bin" && \
	 mkdir -p $(eIQDESTDIR)/usr/local/bin && mkdir -p $(eIQDESTDIR)/usr/local/include && \
	 mkdir -p $(eIQDESTDIR)/usr/local/lib && mkdir -p $(eIQDESTDIR)/usr/share/tensorflow && \
	 if [ ! -d /usr/share/doc/libboost-all-dev -o ! -f /usr/include/snappy.h ]; then \
	     sudo apt update && sudo apt install -y $(CAFFE_DEPENDENT_PKG); \
	 fi; \
	 if [ ! -d /usr/share/doc/python3-wheel ]; then \
	     sudo apt update && sudo apt install -y $(TENSORFLOW_DEP_APT_PKG); \
	 fi; \
	 if [ ! -d /usr/local/lib/python3.6/dist-packages/keras_applications -a \
	      ! -d ~/.local/lib/python3.6/site-packages/keras_applications ]; then \
	    pip3 install $(TENSORFLOW_DEP_PIP_PKG); \
	 fi; \
	 if [ ! -f $(RFSDIR)/etc/buildinfo ]; then \
	     bld -i mkrfs -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi; \
	 if [ ! -f $(RFSDIR)/usr/lib/aarch64-linux-gnu/libavresample.so ]; then \
	     [ -n "$(http_proxy)" ] && sudo cp -f /etc/apt/apt.conf $(RFSDIR)/etc/apt/; \
	     sudo chroot $(RFSDIR) apt update && sudo chroot $(RFSDIR) apt install -y $(TARGET_DEPENDENT_PKG); \
	 fi



crosspyconfig:
	@if [ ! -f /usr/aarch64-linux-gnu/include/aarch64-linux-gnu/python3.8/pyconfig.h ]; then \
	     if [ ! -f $(RFSDIR)/usr/include/aarch64-linux-gnu/python3.8/pyconfig.h ]; then \
		 bld -i mkrfs -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML); \
	     fi && \
	     sudo mkdir -p /usr/aarch64-linux-gnu/include/aarch64-linux-gnu/python3.8 && \
	     sudo cp -f $(RFSDIR)/usr/include/aarch64-linux-gnu/python3.8/pyconfig.h \
	     /usr/aarch64-linux-gnu/include/aarch64-linux-gnu/python3.8/; \
	 fi


eiq_install:
	@[ ! -f $(RFSDIR)/etc/buildinfo ] && echo building dependent $(RFSDIR) && \
	 bld -i mkrfs -r ubuntu:$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML) || \
	 echo target $(RFSDIR) exist && \
	 $(call fbprint_n,"Installing eIQ from $(eIQDESTDIR) to target $(RFSDIR) ...") && \
	 cp_args="-Prf --preserve=mode,timestamps --no-preserve=ownership" && \
	 sudo cp $$cp_args $(eIQDESTDIR)/* $(RFSDIR)/ && \
	 [ $(HOSTARCH) != aarch64 ] && chrootopt="sudo chroot $(RFSDIR)" || echo Running on $(HOSTARCH) && \
	 $$chrootopt python3 -m pip install /usr/share/onnxruntime/onnxruntime-1.1.2-cp38-cp38-linux_aarch64.whl && \
	 $$chrootopt python3 -m pip install /usr/share/armnn/pyarmnn-22.0.0-cp38-cp38-linux_aarch64.whl && \
	 $(call fbprint_n,"eIQ installation completed successfully")




eiq_pack:
	@$(call fbprint_n,"Packing $(eIQDESTDIR)") && cd $(eIQDESTDIR) && \
	 sudo tar czf $(FBOUTDIR)/images/components_$(DESTARCH)_$(DISTROTYPE)_$(DISTROSCALE)_eIQ.tgz * && \
	 touch $(eIQDIR)/.eiqdone && \
	 $(call fbprint_d,"$(FBOUTDIR)/images/components_$(DESTARCH)_$(DISTROTYPE)_$(DISTROSCALE)_eIQ.tgz")



eiq_clean:
	@echo Cleaning for eIQ components ... && \
	 rm -rf $(eIQDIR)/armcl/build $(eIQDIR)/armnn/build $(eIQDIR)/opencv/build \
	    $(eIQDIR)/caffe/.build_release $(eIQDIR)/onnxruntime/build \
	    $(eIQDIR)/flatbuffer/{CMakeFiles,libflatbuffers.*,*.cmake,Makefile,CMakeCache.txt,flat*} \
	    $(eIQDESTDIR) $(eIQDIR)/protobuf/*build $(eIQDIR)/tflite/tensorflow/lite/tools/make/gen \
	    $(eIQDIR)/tflite/tensorflow/lite/tools/pip_package/gen \
	    $(eIQDIR)/.eiqdone && \
	$(call fbprint_n,"Clean eIQ components")

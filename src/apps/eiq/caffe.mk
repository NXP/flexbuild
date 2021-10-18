#
# Copyright 2019-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



caffe: dependency boost
ifeq ($(CONFIG_CAFFE), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu ] && exit || true && \
	 $(call fbprint_b,"caffe") && \
	 $(call repo-mngr,fetch,caffe,apps/eiq) && \
	 cd $(eIQDIR)/caffe && \
	 if [ ! -d $(eIQDESTDIR)/usr/local/include/google/protobuf ]; then \
	     bld -c protobuf -r $(DISTROTYPE):$(DISTROSCALE) -f $(CFGLISTYML); \
	 fi && \
	 cp Makefile.config.example Makefile.config && \
	 sed -i "/^# CPU_ONLY := 1/s/#//g" Makefile.config && \
	 sed -i "/^# USE_OPENCV := 0/s/#//g" Makefile.config && \
	 sed -i "/^INCLUDE_DIRS/a INCLUDE_DIRS += /usr/include/hdf5/serial \
	     $(eIQDESTDIR)/usr/local/include/" Makefile.config && \
	 sed -i "/^LIBRARY_DIRS/a LIBRARY_DIRS += /usr/lib/`uname -i`-linux-gnu/hdf5/serial \
	     $(eIQDIR)/protobuf/host_build/usr/local/lib" Makefile.config && \
	 export PATH=$(eIQDIR)/protobuf/host_build/usr/local/bin/:$(PATH) && \
	 export LD_LIBRARY_PATH=$(eIQDIR)/protobuf/host_build/usr/local/lib:$(LD_LIBRARY_PATH) && \
	 make -j$(JOBS) proto  && \
	 $(call fbprint_d,"caffe")
endif
endif

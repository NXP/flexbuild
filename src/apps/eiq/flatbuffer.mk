# Copyright 2019-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause




flatbuffer: dependency
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu ] && exit || \
	 $(call fbprint_b,"flatbuffer") && \
	 $(call repo-mngr,fetch,flatbuffer,apps/eiq) && \
	 cd $(eIQDIR) && \
	 if [ ! -d flatbuffer_host ]; then \
	     mv flatbuffer flatbuffer_host && \
	     cd flatbuffer_host && \
	     cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release \
	       -DFLATBUFFERS_BUILD_SHAREDLIB=ON \
	       -DFLATBUFFERS_BUILD_TESTS=OFF && \
	     $(MAKE) -j$(JOBS) && cd ..; \
	 fi && \
	 $(call repo-mngr,fetch,flatbuffer,apps/eiq) && \
	 cd flatbuffer && \
	 CXX=$(CROSS_COMPILE)g++ CC=$(CROSS_COMPILE)gcc  \
	 cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release \
	     -DCMAKE_INSTALL_SO_NO_EXE=0 \
	     -DFLATBUFFERS_BUILD_SHAREDLIB=ON \
	     -DCMAKE_NO_SYSTEM_FROM_IMPORTED=1 \
	     -DFLATBUFFERS_BUILD_TESTS=OFF \
	     -DCMAKE_CXX_FLAGS=-fPIC \
	     -DFLATBUFFERS_FLATC_EXECUTABLE=../flatbuffer_host/flatc && \
	 $(MAKE) -j$(JOBS) && \
	 cp -f flatc $(eIQDESTDIR)/usr/local/bin && \
	 $(call fbprint_d,"flatbuffer")
endif

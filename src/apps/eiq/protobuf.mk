# Copyright 2019-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



protobuf:
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu ] && exit || \
	 $(call fbprint_b,"protobuf") && \
	 $(call repo-mngr,fetch,protobuf,apps/eiq) && \
	 cd $(eIQDIR)/protobuf && \
	 ./autogen.sh && \
	 mkdir -p host_build && cd host_build && \
	 ../configure  && \
	 make install -j$(JOBS) DESTDIR=$(eIQDIR)/protobuf/host_build && \
	 cd .. && mkdir -p arm64_build && cd arm64_build && \
	 ../configure --host=aarch64-linux --prefix=/usr/local \
		      CC=$(CROSS_COMPILE)gcc CXX=$(CROSS_COMPILE)g++ \
		      --with-protoc=$(eIQDIR)/protobuf/host_build/usr/local/bin/protoc && \
	 $(MAKE) install -j$(JOBS) DESTDIR=$(eIQDESTDIR) && \
	 $(call fbprint_d,"protobuf")
endif

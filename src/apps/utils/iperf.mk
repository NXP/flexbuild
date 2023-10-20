# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause




iperf:
	@[ $(DESTARCH) != arm64 -o $(DISTROVARIANT) = base ] && exit || \
	 $(call fbprint_b,"iperf") && \
	 $(call repo-mngr,fetch,iperf,apps/utils) && \
	 cd $(UTILSDIR)/iperf && \
	 export CC=aarch64-linux-gnu-gcc && \
	 export CXX=aarch64-linux-gnu-g++ && \
	 ./configure --host=aarch64 && \
	 $(MAKE) -j$(JOBS) && \
	 $(MAKE) install DESTDIR=$(DESTDIR) && \
	 $(call fbprint_d,"iperf")

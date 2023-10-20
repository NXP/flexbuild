# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


iproute2_src_url ?= https://mirrors.edge.kernel.org/pub/linux/utils/net/iproute2/iproute2-4.15.0.tar.gz

ceetm:
	@[ $(DESTARCH) != arm64 -o $(SOCFAMILY) != LS -o $(DISTROVARIANT) = tiny -o $(DISTROVARIANT) = base ] && exit || \
	 $(call fbprint_b,"CEETM") && \
	 $(call repo-mngr,fetch,ceetm,apps/networking) && \
	 cd $(NETDIR)/ceetm && \
	 if [ ! -f iproute2-4.15.0/tc/tc_util.h ]; then \
	     wget --no-check-certificate $(iproute2_src_url) && \
	     tar xzf iproute2-4.15.0.tar.gz; \
	 fi && \
	 export IPROUTE2_DIR=$(NETDIR)/ceetm/iproute2-4.15.0 && \
	 $(MAKE) clean && \
	 $(MAKE) -j$(JOBS) && \
	 $(MAKE) install && \
	 $(call fbprint_d,"CEETM")

# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



IPROUTE2_PKG := iproute2-6.13.0
iproute2_src_url ?= https://mirrors.edge.kernel.org/pub/linux/utils/net/iproute2/$(IPROUTE2_PKG).tar.gz

ceetm:
	@[ $(DESTARCH) != arm64 -o $(SOCFAMILY) != LS  ] && exit || \
	 $(call download_repo,ceetm,apps/networking) && \
	 $(call patch_apply,ceetm,apps/networking) && \
	 $(call fbprint_b,"CEETM") && \
	 cd $(NETDIR)/ceetm && \
	 if [ ! -d $(IPROUTE2_PKG) ]; then \
		 rm -rf $(IPROUTE2_PKG).tar.gz; \
	     $(WGET) --no-check-certificate $(iproute2_src_url) $(LOG_MUTE); \
	     tar xzf $(IPROUTE2_PKG).tar.gz; \
	 fi && \
	 export IPROUTE2_DIR=$(NETDIR)/ceetm/$(IPROUTE2_PKG) && \
	 export CC=$(CROSS_COMPILE)gcc && \
	 $(MAKE) clean && \
	 $(MAKE) -j$(JOBS) $(LOG_MUTE) && \
	 $(MAKE) install $(LOG_MUTE) && \
	 install -d $(DESTDIR)/usr/lib/aarch64-linux-gnu/tc && \
	 mv $(DESTDIR)/usr/lib/tc/* $(DESTDIR)/usr/lib/aarch64-linux-gnu/tc/ && \
	 $(call fbprint_d,"CEETM")

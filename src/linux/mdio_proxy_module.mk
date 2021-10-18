# Copyright 2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



mdio_proxy_module:
ifeq ($(CONFIG_MDIO_PROXY_MODULE), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(SOCFAMILY) != LS ] && exit || true && \
	 $(call repo-mngr,fetch,mdio_proxy_module,linux) && \
	 $(call repo-mngr,fetch,$(KERNEL_TREE),linux) && \
	 if [ ! -d $(FBOUTDIR)/linux/kernel/$(DESTARCH)/$(SOCFAMILY) ]; then \
	     bld -c linux -a $(DESTARCH) -p $(SOCFAMILY) -f $(CFGLISTYML); \
	 fi && \
	 curbrch=`cd $(KERNEL_PATH) && git branch | grep ^* | cut -d' ' -f2` && \
	 opdir=$(KERNEL_OUTPUT_PATH)/$$curbrch && mkdir -p $$opdir && \
	 cd $(PKGDIR)/linux/mdio_proxy_module && \
	 $(call fbprint_b,"mdio-proxy-module") && \
	 $(MAKE) KBUILD_DIR=$(KERNEL_PATH) O=$$opdir && \
	 cp -f mdio-proxy.ko $$opdir/tmp/lib/modules/*/extra && \
	 $(call fbprint_d,"mdio_proxy_module")
endif
endif

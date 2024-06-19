# Copyright 2021-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



mdio_proxy_module:
	@[ $(SOCFAMILY) != LS ] && exit || true && \
	 $(call repo-mngr,fetch,mdio_proxy_module,linux) && \
	 $(call repo-mngr,fetch,$(KERNEL_TREE),linux) && \
	 if [ ! -d $(FBOUTDIR)/linux/kernel/$(DESTARCH)/$(SOCFAMILY) ]; then \
	     bld linux -a $(DESTARCH) -p $(SOCFAMILY) -f $(CFGLISTYML); \
	 fi && \
	 curbrch=`cd $(KERNEL_PATH) && git branch | grep ^* | cut -d' ' -f2` && \
	 opdir=$(KERNEL_OUTPUT_PATH)/$$curbrch && mkdir -p $$opdir && \
	 \
	 cd $(PKGDIR)/linux/mdio_proxy_module && \
	 $(call fbprint_b,"mdio-proxy-module") && \
	 $(MAKE) -j$(JOBS) KBUILD_DIR=$(KERNEL_PATH) O=$$opdir && \
	 cp -f mdio-proxy.ko $$opdir/tmp/lib/modules/*/kernel/drivers/net/mdio/ && \
	 $(call fbprint_d,"mdio_proxy_module")

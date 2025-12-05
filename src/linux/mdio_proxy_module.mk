# Copyright 2021-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



mdio_proxy_module:
	@[ $(SOCFAMILY) != LS ] && exit || true && \
	 $(call download_repo,mdio_proxy_module,linux) && \
	 $(call download_repo,linux,linux) && \
	 if [ ! -d $(FBOUTDIR)/linux/kernel/$(DESTARCH)/$(SOCFAMILY) ]; then \
	     bld linux -m $(MACHINE); \
	 fi && \
	 opdir=$(KERNEL_OUTPUT_PATH)/$(KERNEL_BRANCH) && mkdir -p $$opdir && \
	 \
	 cd $(PKGDIR)/linux/mdio_proxy_module && \
	 $(call fbprint_b,"mdio-proxy-module") && \
	 $(MAKE) -j$(JOBS) KBUILD_DIR=$(KERNEL_PATH) O=$$opdir $(LOG_MUTE) && \
	 cp -f mdio-proxy.ko $$opdir/tmp/lib/modules/*/kernel/drivers/net/mdio/ && \
	 $(call fbprint_d,"mdio_proxy_module")

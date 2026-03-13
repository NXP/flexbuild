# Copyright 2021-2023,2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



mdio_proxy_module:
	@$(call download_repo,mdio_proxy_module,linux)
	$(call patch_apply,mdio_proxy_module,linux)
	$(call fbprint_b,"mdio-proxy-module")
	cd $(PKGDIR)/linux/mdio_proxy_module
	krelease=$$(cat "$(KOUTDIR)/include/config/kernel.release" 2>/dev/null)
	$(MAKE) KBUILD_DIR=$(KERNEL_PATH) O=$(KOUTDIR) $(LOG_MUTE)
	cp -f mdio-proxy.ko $(KOUTDIR)/tmp/lib/modules/"$$krelease"/kernel/drivers/net/mdio/
	$(call fbprint_d,"mdio_proxy_module")

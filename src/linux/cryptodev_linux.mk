# Copyright 2017-2024,2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


cryptodev_linux:
	@$(call download_repo,cryptodev_linux,linux)
	$(call patch_apply,cryptodev_linux,linux)
	$(call fbprint_b,"cryptodev_linux")
	export KERNEL_MAKE_OPTS="-lcrypto"
	$(MAKE) KERNEL_DIR=$(KERNEL_PATH) O=$(KOUTDIR) \
		-C $(PKGDIR)/linux/cryptodev_linux $(LOG_MUTE)
	$(MAKE) install KERNEL_DIR=$(KERNEL_PATH) O=$(KOUTDIR) INSTALL_MOD_PATH=$(KOUTDIR)/tmp \
		-C $(PKGDIR)/linux/cryptodev_linux $(LOG_MUTE)
	$(call fbprint_d,"cryptodev_linux")

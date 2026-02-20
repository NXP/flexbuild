# Copyright 2017-2023,2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


lttng_modules:
	@$(call download_repo,lttng_modules,linux)
	$(call patch_apply,lttng_modules,linux)
	$(call fbprint_b,"LTTng modules")
	cd $(PKGDIR)/linux/lttng_modules
	$(MAKE) KERNELDIR=$(KERNEL_PATH) O=$(KOUTDIR) \
		-C $(PKGDIR)/linux/lttng_modules $(LOG_MUTE)
	$(MAKE) KERNELDIR=$(KERNEL_PATH) O=$(KOUTDIR) modules_install \
		-C $(PKGDIR)/linux/lttng_modules $(LOG_MUTE)
	$(call fbprint_d,"LTTng modules")

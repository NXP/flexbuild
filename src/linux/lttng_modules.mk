# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


lttng_modules:
	@$(call download_repo,lttng_modules,linux) && \
	 $(call download_repo,linux,linux) && \
	 opdir=$(KERNEL_OUTPUT_PATH)/$(KERNEL_BRANCH) && mkdir -p $$opdir && \
	 if ! grep CONFIG_STACKTRACE=y $$opdir/.config 1>/dev/null 2>&1; then \
	     bld linux -B fragment:lttng.config -m $(MACHINE); \
	 fi && \
	 cd $(PKGDIR)/linux/lttng_modules && \
	 $(call fbprint_b,"LTTng modules") && \
	 $(MAKE) KERNELDIR=$(KERNEL_PATH) O=$$opdir $(LOG_MUTE) && \
	 $(MAKE) KERNELDIR=$(KERNEL_PATH) O=$$opdir modules_install $(LOG_MUTE) && \
	 $(call fbprint_d,"LTTng modules")

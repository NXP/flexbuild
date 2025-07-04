# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


lttng_modules:
	@$(call repo-mngr,fetch,lttng_modules,linux) && \
	 $(call repo-mngr,fetch,$(KERNEL_TREE),linux) && \
	 curbrch=`cd $(KERNEL_PATH) && git branch | grep ^* | cut -d' ' -f2` && \
	 opdir=$(KERNEL_OUTPUT_PATH)/$$curbrch && mkdir -p $$opdir && \
	 if ! grep CONFIG_STACKTRACE=y $$opdir/.config 1>/dev/null 2>&1; then \
	     bld linux -B fragment:lttng.config -a $(DESTARCH) -p $(SOCFAMILY); \
	 fi && \
	 cd $(PKGDIR)/linux/lttng_modules && \
	 $(call fbprint_b,"LTTng modules") && \
	 $(MAKE) KERNELDIR=$(KERNEL_PATH) O=$$opdir $(LOG_MUTE) && \
	 $(MAKE) KERNELDIR=$(KERNEL_PATH) O=$$opdir modules_install $(LOG_MUTE) && \
	 $(call fbprint_d,"LTTng modules")

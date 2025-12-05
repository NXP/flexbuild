# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


perf:
	@$(call download_repo,linux,linux) && \
	 cd $(PKGDIR)/linux && \
	 opdir=$(KERNEL_OUTPUT_PATH)/$(KERNEL_BRANCH) && \
	 $(call fbprint_b,"kernel tools/perf") && \
	 mkdir -p $$opdir && \
	 if [ ! -f $$opdir/.config ]; then \
	     $(MAKE) $(KERNEL_CFG) -C $(KERNEL_PATH) O=$$opdir 1>/dev/null; \
	 fi && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 $(MAKE) -j$(JOBS) tools/perf -C $(KERNEL_PATH) O=$$opdir NO_LIBELF=1 NO_LIBTRACEEVENT=1 $(LOG_MUTE) && \
	 cp $$opdir/tools/perf/perf $(FBOUTDIR)/linux/$(KERNEL_TREE)/$(DESTARCH)/$(SOCFAMILY) && \
	 ls -l $(FBOUTDIR)/linux/$(KERNEL_TREE)/$(DESTARCH)/$(SOCFAMILY)/perf $(LOG_MUTE) && \
	 $(call fbprint_d,"kernel tools/perf")

# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


perf:
	@$(call repo-mngr,fetch,$(KERNEL_TREE),linux) && \
	 cd $(PKGDIR)/linux && \
	 curbrch=`cd $(KERNEL_PATH) && git branch | grep ^* | cut -d' ' -f2` && \
	 opdir=$(KERNEL_OUTPUT_PATH)/$$curbrch && \
	 $(call fbprint_b,"kernel tools/perf") && \
	 mkdir -p $$opdir && \
	 if [ ! -f $$opdir/.config ]; then \
	     $(MAKE) $(KERNEL_CFG) -C $(KERNEL_PATH) O=$$opdir 1>/dev/null; \
	 fi && \
	 $(MAKE) -j$(JOBS) tools/perf -C $(KERNEL_PATH) O=$$opdir && \
	 cp $$opdir/tools/perf/perf $(FBOUTDIR)/linux/$(KERNEL_TREE)/$(DESTARCH)/$(SOCFAMILY) && \
	 ls -l $(FBOUTDIR)/linux/$(KERNEL_TREE)/$(DESTARCH)/$(SOCFAMILY)/perf && \
	 $(call fbprint_d,"kernel tools/perf")

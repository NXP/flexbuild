# Copyright 2017-2023,2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


perf:
	@$(call fbprint_b,"kernel tools/perf")
	cd $(PKGDIR)/linux
	$(MAKE) tools/perf -C $(KERNEL_PATH) O=$(KOUTDIR) NO_LIBELF=1 NO_LIBTRACEEVENT=1 $(LOG_MUTE)
	cp $(KOUTDIR)/tools/perf/perf $(FBOUTDIR)/linux/$(KERNEL_TREE)/arm64/$(SOCFAMILY)
	$(call fbprint_d,"kernel tools/perf in: $(FBOUTDIR)/linux/$(KERNEL_TREE)/$(DESTARCH)/$(SOCFAMILY)")

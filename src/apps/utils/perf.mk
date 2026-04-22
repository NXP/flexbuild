# Copyright 2017-2023,2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


perf:
	@$(call fbprint_b,"kernel tools/perf")
	cd $(PKGDIR)/linux
	$(MAKE) tools/perf -C $(KERNEL_PATH) O=$(KOUTDIR) \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		EXTRA_CFLAGS="--sysroot=$(RFSDIR) -I$(RFSDIR)/usr/include" \
		LDFLAGS="--sysroot=$(RFSDIR) -L$(RFSDIR)/usr/lib -L$(RFSDIR)/lib/aarch64-linux-gnu \
		-L$(RFSDIR)/usr/lib/aarch64-linux-gnu" \
		$(LOG_MUTE)
	mkdir -p $(DESTDIR)/usr/bin/
	cp -f $(KOUTDIR)/tools/perf/perf $(DESTDIR)/usr/bin/
	$(call fbprint_d,"kernel tools/perf")

# Copyright 2021-2024,2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# A library to retrieve i.MX GPU performance data



libgpuperfcnt:
	@$(call dl_by_wget,libgpuperfcnt_bin,libgpuperfcnt.bin)
	cd $(GRAPHICSDIR)
	if [ ! -d "$(GRAPHICSDIR)"/libgpuperfcnt ]; then
		chmod +x $(FBDIR)/dl/libgpuperfcnt.bin
		$(FBDIR)/dl/libgpuperfcnt.bin --auto-accept --force $(LOG_MUTE)
		mv $(basename $(notdir $(repo_libgpuperfcnt_bin_url))) libgpuperfcnt
	fi
	$(call fbprint_b,"libgpuperfcnt")
	mkdir -p $(DESTDIR)
	cp -af libgpuperfcnt/usr $(DESTDIR)/
	$(call fbprint_d,"libgpuperfcnt")

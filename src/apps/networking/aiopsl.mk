# Copyright 2017-2023,2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
# only used on: lx216, ls1088 and ls2088



aiopsl:
	@$(call download_repo,aiopsl,apps/networking)
	 $(call patch_apply,aiopsl,apps/networking)
	 $(call fbprint_b,"aiopsl")
	 cd $(NETDIR)/aiopsl
	 mkdir -p $(DESTDIR)/usr/local/aiop/bin
	 cp -af misc/setup/scripts $(DESTDIR)/usr/local/aiop
	 cp -af misc/setup/traffic_files $(DESTDIR)/usr/local/aiop
	 cp -af demos/images/* $(DESTDIR)/usr/local/aiop/bin
	 $(call fbprint_d,"aiopsl")

# Copyright 2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


aquantia_firmware:
	$(call fbprint_b,"aquantia_fw")
	mkdir -p $(DESTDIR)/root/aquantia_firmware && \
	cd $(DESTDIR)/root/aquantia_firmware && wget $(repo_aquantia_fw_src_url)
	$(call fbprint_d,"aquantia_fw")

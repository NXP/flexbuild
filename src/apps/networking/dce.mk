# Copyright 2017-2023,2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
#
# SDK Networking Components


dce:
	@$(call download_repo,dce,apps/networking,submod)
	 $(call patch_apply,dce,apps/networking)
	 $(call fbprint_b,"dce")
	 cd $(NETDIR)/dce
	 sed -i 's/DESTDIR)\/sbin/DESTDIR)\/usr\/bin/' Makefile
	 sed -i 's/-Wwrite-strings -Wno-error/-Wwrite-strings -fcommon -Wno-error/' lib/qbman_userspace/Makefile
	 $(MAKE) clean $(LOG_MUTE)
	 $(MAKE) ARCH=aarch64 $(LOG_MUTE)
	 $(MAKE) install $(LOG_MUTE)
	 $(call fbprint_d,"dce")

# Copyright 2017-2023,2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



crconf:
	 @$(call download_repo,crconf,apps/security)
	 $(call patch_apply,crconf,apps/security)
	 $(call fbprint_b,"crconf")
	 sed -i -e 's/CC =/CC ?=/' -e 's/DESTDIR=/DESTDIR?=/' $(SECDIR)/crconf/Makefile
	 cd $(SECDIR)/crconf
	 export CC=$(CROSS_COMPILE)gcc
	 export DESTDIR=${DESTDIR}/usr/local
	 $(MAKE) clean $(LOG_MUTE)
	 $(MAKE) $(LOG_MUTE)
	 $(MAKE) install $(LOG_MUTE)
	 $(call fbprint_d,"crconf")

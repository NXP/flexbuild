# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
#
# SDK Networking Components


dce:
	@[ $(SOCFAMILY) != LS -o $(DISTROVARIANT) != server ] && exit || \
	 $(call download_repo,dce,apps/networking,submod) && \
	 $(call patch_apply,dce,apps/networking) && \
	 $(call fbprint_b,"dce") && \
	 cd $(NETDIR)/dce && \
	 sed -i 's/DESTDIR)\/sbin/DESTDIR)\/usr\/bin/' Makefile && \
	 sed -i 's/-Wwrite-strings -Wno-error/-Wwrite-strings -fcommon -Wno-error/' lib/qbman_userspace/Makefile && \
	 make clean  && \
	 $(MAKE) -j$(JOBS) ARCH=aarch64 $(LOG_MUTE) && \
	 $(MAKE) -j$(JOBS) install $(LOG_MUTE) && \
	 $(call fbprint_d,"dce")

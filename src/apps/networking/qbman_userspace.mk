# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause




qbman_userspace:
	@[ $(SOCFAMILY) != LS -o $(DISTROVARIANT) != server ] && exit || \
	 $(call fbprint_b,"qbman_userspace") && \
	 $(call repo-mngr,fetch,qbman_userspace,apps/networking) && \
	 cd $(NETDIR)/qbman_userspace && \
	 export PREFIX=/usr && \
	 export ARCH=aarch64 && \
	 $(MAKE) -j$(JOBS) $(LOG_MUTE) && \
	 cp -f lib_aarch64_static/libqbman.a $(DESTDIR)/usr/lib && \
	 cp -f include/*.h $(DESTDIR)/usr/include && \
	 $(call fbprint_d,"qbman_userspace")

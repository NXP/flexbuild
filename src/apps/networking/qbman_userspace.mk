# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause




qbman_userspace:
ifeq ($(CONFIG_QBMAN_USERSPACE), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(SOCFAMILY) != LS -a $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = desktop -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"qbman_userspace") && \
	 $(call repo-mngr,fetch,qbman_userspace,apps/networking) && \
	 cd $(NETDIR)/qbman_userspace && \
	 export PREFIX=/usr/local && \
	 export ARCH=aarch64 && \
	 $(MAKE) && \
	 cp -f lib_aarch64_static/libqbman.a $(DESTDIR)/usr/local/lib && \
	 cp -f include/*.h $(DESTDIR)/usr/local/include && \
	 $(call fbprint_d,"qbman_userspace")
endif
endif

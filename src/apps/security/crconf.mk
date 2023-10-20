# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



crconf:
	@[ $(DISTROVARIANT) = base -o $(DISTROVARIANT) = tiny ] && exit || \
	 $(call fbprint_b,"crconf") && \
	 $(call repo-mngr,fetch,crconf,apps/security) && \
	 sed -i -e 's/CC =/CC ?=/' -e 's/DESTDIR=/DESTDIR?=/' $(SECDIR)/crconf/Makefile && \
	 cd $(SECDIR)/crconf && \
	 export CC=$(CROSS_COMPILE)gcc && \
	 export DESTDIR=${DESTDIR}/usr/local && \
	 $(MAKE) clean && \
	 $(MAKE) -j$(JOBS) && \
	 $(MAKE) install && \
	 $(call fbprint_d,"crconf")

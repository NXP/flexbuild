# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


keyctl_caam:
ifeq ($(CONFIG_KEYCTL_CAAM), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = desktop -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"keyctl_caam") && \
	 $(call repo-mngr,fetch,keyctl_caam,apps/security) && \
	 cd $(SECDIR)/keyctl_caam && \
	 $(MAKE) CC=$(CROSS_COMPILE)gcc DESTDIR=$(DESTDIR) install && \
	 $(call fbprint_d,"keyctl_caam")
endif
endif

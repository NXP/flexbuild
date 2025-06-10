# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


keyctl_caam:
ifeq ($(CONFIG_OPENSSL),y)
	@[ $(DISTROVARIANT) = base -o $(DISTROVARIANT) = tiny ] && exit || \
	 $(call fbprint_b,"keyctl_caam") && \
	 $(call repo-mngr,fetch,keyctl_caam,apps/security) && \
	 cd $(SECDIR)/keyctl_caam && \
	 export OPENSSL_PATH=$(SECDIR)/openssl && \
	 $(MAKE) CC=$(CROSS_COMPILE)gcc DESTDIR=$(DESTDIR) install $(LOG_MUTE) && \
	 $(call fbprint_d,"keyctl_caam")
endif

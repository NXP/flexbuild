# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



optee_client:
ifeq ($(CONFIG_OPTEE), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = tiny -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"optee_client") && \
	 $(call repo-mngr,fetch,optee_client,apps/security) && \
	 cd $(SECDIR)/optee_client && \
	 $(MAKE) -j$(JOBS) ARCH=arm64 && \
	 mkdir -p $(DESTDIR)/usr/local/lib && \
	 ln -sf $(DESTDIR)/lib/libteec.so $(DESTDIR)/usr/local/lib/libteec.so && \
	 $(call fbprint_d,"optee_client")
endif
else
	@$(call fbprint_w,INFO: OPTEE is not enabled by default)
endif

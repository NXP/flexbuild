# Copyright 2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# UUU (Universal Update Utility), mfgtools

uuu:
ifeq ($(CONFIG_UUU), "y")
	@[ $(SOCFAMILY) != IMX ] && exit || \
	 $(call fbprint_b,"UUU") && \
	 $(call repo-mngr,fetch,uuu,apps/generic) && \
	 cd $(GENDIR)/uuu && \
	 cmake -Wno-dev . && \
	 $(MAKE) && \
	 install uuu/uuu $(FBDIR) && \
	 install uuu/uuu $(FBOUTDIR)/images && \
	 $(call fbprint_d,"UUU")
endif

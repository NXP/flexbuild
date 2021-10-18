# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


include $(FBDIR)/configs/$(CONFIGLIST)

.PHONY: linux bsp apps misc

apps:
	@$(MAKE) -C $(FBDIR)/src/$@

$(BSP_REPO_LIST):
	@$(MAKE) -C $(FBDIR)/src/bsp $@

$(LINUX_REPO_LIST) linux-deb linux-modules:
	@$(MAKE) -C $(FBDIR)/src/linux $@

$(APPS_REPO_LIST) $(EIQ_REPO_LIST) generic security \
networking graphics multimedia connectivity:
	@$(MAKE) -C $(FBDIR)/src/apps $@

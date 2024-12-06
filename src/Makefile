# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


include $(FBDIR)/configs/$(CONFIGLIST)

.PHONY: linux bsp apps

apps:
	@$(MAKE) -C $(FBDIR)/src/$@

$(BSP_REPO_LIST):
	@$(MAKE) -C $(FBDIR)/src/bsp $@

$(LINUX_REPO_LIST) linux-headers linux-deb linux-modules:
	@$(MAKE) -C $(FBDIR)/src/linux $@

$(APPS_REPO_LIST) utils security ml gopoint robotics \
networking graphics multimedia connectivity:
	@$(MAKE) -C $(FBDIR)/src/apps $@

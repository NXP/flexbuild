# Copyright 2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# RDEPENDS: python3-packaging python3-paramiko iproute2 iproute2-tc python3-matplotlib


GPNT_APPS_FOLDER = /opt/gopoint-apps


imx_demos_list:
	@[ $(SOCFAMILY) != IMX -o $(DISTROVARIANT) = tiny -o $(DISTROVARIANT) = base ] && exit || \
	 $(call fbprint_b,"imx_demos_list") && \
	 $(call repo-mngr,fetch,imx_demos_list,apps/gopoint) && \
	 cd $(GPDIR)/imx_demos_list && \
	 if [ -d $(FBDIR)/patch/imx_demos_list ] && [ ! -f .patchdone ]; then \
	     git am $(FBDIR)/patch/imx_demos_list/*.patch $(LOG_MUTE) && touch .patchdone; \
	 fi && \
	 mkdir -p $(DESTDIR)/$(GPNT_APPS_FOLDER) && \
	 cp -r * $(DESTDIR)/$(GPNT_APPS_FOLDER) && \
	 chmod 777 $(DESTDIR)/$(GPNT_APPS_FOLDER) && \
	 $(call fbprint_d,"imx_demos_list")

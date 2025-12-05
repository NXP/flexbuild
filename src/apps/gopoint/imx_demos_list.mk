# Copyright 2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# RDEPENDS: python3-packaging python3-paramiko iproute2 iproute2-tc python3-matplotlib


GPNT_APPS_FOLDER = /opt/gopoint-apps


imx_demos_list:
	@[ $(SOCFAMILY) != IMX  ] && exit || \
	 $(call download_repo,imx_demos_list,apps/gopoint) && \
	 $(call patch_apply,imx_demos_list,apps/gopoint) && \
	 $(call fbprint_b,"imx_demos_list") && \
	 cd $(GPDIR)/imx_demos_list && \
	 mkdir -p $(DESTDIR)/$(GPNT_APPS_FOLDER) && \
	 cp -r * $(DESTDIR)/$(GPNT_APPS_FOLDER) && \
	 chmod 777 $(DESTDIR)/$(GPNT_APPS_FOLDER) && \
	 $(call fbprint_d,"imx_demos_list")

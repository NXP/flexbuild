# Copyright 2025 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# section: iMX gopoint
# description: NXP nxp_demo_experience_assets
# 
# depends on: alsa-lib nxp-afe imx-voiceui
#

nxp_demo_experience_assets:
ifeq ($(CONFIG_NXP_DEMO_EXPERIENCE_ASSETS),y)
	@[ $(DISTROVARIANT) != desktop -o $(SOCFAMILY) != IMX ] && exit || \
	 $(call fbprint_b,"nxp_demo_experience_assets") && \
	 $(call repo-mngr,fetch,nxp_demo_experience_assets,apps/gopoint) && \
	 \
	 $(call fbprint_d,"nxp_demo_experience_assets")
endif

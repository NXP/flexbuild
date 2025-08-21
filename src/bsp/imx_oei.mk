# Copyright 2025 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# The Optional Executable Image (OEI) is an optional plugin loaded and executed by
# Cortex-M processor ROM on many NXP i.MX processors. The Cortex-M is the boot core,
# runs the boot ROM which loads the OEI, and then branches to the OEI. The OEI then
# configures some aspects of the hardware such as DDR config, init TCM ECC, etc.
# There could be multiple OEI images in the boot container. After execution of OEI,
# the processor returns to ROM execution.


imx_oei:
	[[ ! "$(MACHINE)" == *"imx95"* ]] && exit 0 || \
	$(call download_repo,imx_oei,bsp) && \
	$(call patch_apply,imx_oei,bsp) && \
	$(call fbprint_b,"imx_oei") && \
	cd $(BSPDIR)/imx_oei && \
	export PATH=/usr/arm-gnu-toolchain-14.2.rel1-x86_64-arm-none-eabi/bin:$(PATH) && \
	$(MAKE) board=mx95lp4x-15 oei=ddr clean $(LOG_MUTE) && \
	$(MAKE) board=mx95lp4x-15 oei=ddr DEBUG=1 OEI_CROSS_COMPILE=arm-none-eabi- r=B0 $(LOG_MUTE) && \
	$(call fbprint_d,"imx_oei")

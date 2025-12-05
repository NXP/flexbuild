# Copyright 2025 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
# 
# The System Manager (SM) is an application that runs on a Cortex-M processor on many NXP i.MX processors.
# The Cortex-M is the boot core, runs the boot ROM which loads the SM (and other boot code),
# and then branches to the SM. The SM then configures some aspects of the hardware such as isolation
# mechanisms and then starts other cores in the system. After starting these cores, it enters a service
# mode where it provides access to clocking, power, sensor, and pin control via a client RPC API based
# on ARM's System Control and Management Interface (SCMI). To facilitate isolation between cores,
# the SM partitions the SoC into logical machines (LM) which have statically configurable access rights
# to both hardware and RPC API calls.


imx_sm:
	[[ ! "$(MACHINE)" == *"imx95"* ]] && exit 0 || \
	$(call download_repo,imx_sm,bsp) && \
	$(call patch_apply,imx_sm,bsp) && \
	$(call fbprint_b,"imx_sm") && \
	cd $(BSPDIR)/imx_sm && \
	export PATH=/usr/arm-gnu-toolchain-14.2.rel1-x86_64-arm-none-eabi/bin:$(PATH) && \
	$(MAKE) V=1 SM_CROSS_COMPILE=arm-none-eabi- config=mx95evk clean $(LOG_MUTE) && \
	$(MAKE) V=1 SM_CROSS_COMPILE=arm-none-eabi- config=mx95evk M=2 $(LOG_MUTE) && \
	$(call fbprint_d,"imx_sm")

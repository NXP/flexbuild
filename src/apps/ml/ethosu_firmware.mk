# Copyright 2023-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# The firmware of Cortex(R)-M33 for Arm(R) Ethos(TM)-U NPU

# COMPATIBLE_MACHINE: imx93

ethosu_firmware:
	@[ $(SOCFAMILY) != IMX -o $(DISTROVARIANT) = tiny -o $(DISTROVARIANT) = base ] && exit || \
	 $(call fbprint_b,"ethosu_firmware") && \
	 $(call repo-mngr,fetch,ethosu_firmware,apps/ml) && \
	 cd $(MLDIR)/ethosu_firmware && \
	 cp -f ethosu_firmware $(DESTDIR)/usr/lib/ && \
	 $(call fbprint_d,"ethosu_firmware")

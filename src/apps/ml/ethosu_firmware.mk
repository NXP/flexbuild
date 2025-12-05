# Copyright 2023-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# The firmware of Cortex(R)-M33 for Arm(R) Ethos(TM)-U NPU

# COMPATIBLE_MACHINE: imx93

ethosu_firmware:
	@[ $${MACHINE:0:5} != imx93  ] && exit || \
	 $(call download_repo,ethosu_firmware,apps/ml) && \
	 $(call patch_apply,ethosu_firmware,apps/ml) && \
	 $(call fbprint_b,"ethosu_firmware") && \
	 cd $(MLDIR)/ethosu_firmware && \
	 cp -f ethosu_firmware $(DESTDIR)/lib/firmware && \
	 $(call fbprint_d,"ethosu_firmware")

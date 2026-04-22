# Copyright 2021-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# i.MX M4/M7/M33 core Demo images



mcore_demo:
	@echo -e "\nInstalling mcore demos for $(MACHINE)"
	mkdir -p $(UTILSDIR)/mcore_demo
	cd $(UTILSDIR)/mcore_demo
	if [ "$(CONFIG_SOC_IMX8MMEVK)" = "y" ]; then
		$(call dl_by_wget,imx8mm_mdemo,imx8mm-m4-demo.bin)
		_SOC=imx8mm; _NAME=imx8mm-m4-demo
	elif [ "$(CONFIG_SOC_IMX8MP)" = "y" ]; then
		$(call dl_by_wget,imx8mp_mdemo,imx8mp-m7-demo.bin)
		_SOC=imx8mp; _NAME=imx8mp-m7-demo
	elif [ "$(CONFIG_SOC_IMX8QMMEK)" = "y" ]; then
		$(call dl_by_wget,imx8qm_mdemo,imx8qm-m4-demo.bin)
		_SOC=imx8qm; _NAME=imx8qm-m4-demo
	elif [ "$(CONFIG_SOC_IMX93)" = "y" ]; then
		$(call dl_by_wget,imx93_mdemo,imx93-m33-demo.bin)
		_SOC=imx93; _NAME=imx93-m33-demo
	elif [ "$(CONFIG_SOC_IMX95)" = "y" ]; then
		$(call dl_by_wget,imx95_mdemo,imx95-m7-demo.bin)
		_SOC=imx95; _NAME=imx95-m7-demo
	else
		exit 0
	fi
	if [ ! -d $${_NAME} ]; then
		chmod +x $(FBDIR)/dl/$${_NAME}.bin
		$(FBDIR)/dl/$${_NAME}.bin --auto-accept --force $(LOG_MUTE)
		mv $${_NAME}-* $${_NAME}
	fi
	mkdir -p $(DESTDIR)/lib/firmware
	cp -af ./$${_NAME}/$${_SOC}* $(DESTDIR)/lib/firmware
	$(call fbprint_d,"mcore_demo")

# Copyright 2023,2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# i.MX DSP Wrapper, Firmware Binary, Codec Libraries for mx8mp, mx8qm, mx8qxp, mx8dx, mx8ulp


ifeq ($(CONFIG_SOC_IMX8M),y)
  HIFI4_PLATFORM = imx8mp
else ifeq ($(CONFIG_SOC_IMX8QMMEK),y)
  HIFI4_PLATFORM = imx8qmqxp
else
 $(error platform is not supported.)
endif


imx_dsp:
	@$(call dl_by_wget,imx_dsp_bin,imx_dsp.bin)
	cd $(MMDIR)
	if [ ! -d "$(MMDIR)"/imx_dsp ]; then
		rm -rf imx-dsp-*
		chmod +x $(FBDIR)/dl/imx_dsp.bin
		$(FBDIR)/dl/imx_dsp.bin --auto-accept --force $(LOG_MUTE)
		set -- imx-dsp-*
		if [ ! -e "$$1" ]; then
			echo "ERROR: 'imx-dsp-*' not found under $(MMDIR)"
			exit 1
		fi
		rm -rf imx_dsp
		mv -fT -- "$$1" imx_dsp
	fi
	$(call fbprint_b,"imx_dsp")
	cd "$(MMDIR)"/imx_dsp
	./configure CC=aarch64-linux-gnu-gcc \
	   --bindir=/unit_tests \
	   --datadir=/lib/firmware \
	   --enable-armv8 \
	   --prefix=/usr $(LOG_MUTE)
	export DESTDIR=$(DESTDIR)
	$(MAKE) $(LOG_MUTE)
	$(MAKE) install $(LOG_MUTE)
	ln -sf hifi4_$(HIFI4_PLATFORM).bin $(DESTDIR)/lib/firmware/imx/dsp/hifi4.bin
	$(call fbprint_d,"imx_dsp")

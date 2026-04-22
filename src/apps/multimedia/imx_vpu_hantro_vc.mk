# Copyright 2021-2024,2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# i.MX vc8000e encoder library on imx8mp


imx_vpu_hantro_vc:
	@$(call dl_by_wget,vpu_hantro_vc_bin,vpu_hantro_vc.bin)
	cd $(MMDIR)
	if [ ! -d "$(MMDIR)"/imx_vpu_hantro_vc ]; then
		chmod +x $(FBDIR)/dl/vpu_hantro_vc.bin
		$(FBDIR)/dl/vpu_hantro_vc.bin --auto-accept --force $(LOG_MUTE)
		mv $(basename $(notdir $(repo_vpu_hantro_vc_bin_url))) imx_vpu_hantro_vc
	fi
	$(call fbprint_b,"imx_vpu_hantro_vc")
	mkdir -p $(DESTDIR)
	cp -af $(MMDIR)/imx_vpu_hantro_vc/usr $(DESTDIR)/
	cp -af $(MMDIR)/imx_vpu_hantro_vc/unit_tests $(DESTDIR)/
	$(call fbprint_d,"imx_vpu_hantro_vc")

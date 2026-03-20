# Copyright 2021-2023,2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# Kernel loadable module verisilicon ISP vvcam v4l2

# isp_vvcam_module/vvcam/readme_v4l2.txt


isp_vvcam_module: $(KERNEL_IMAGE)
	@$(call download_repo,isp_vvcam_module,linux)
	$(call patch_apply,isp_vvcam_module,linux)
	$(call fbprint_b,"isp_vvcam_module")
	export INSTALL_MOD_PATH=$(DESTDIR)
	$(MAKE) KERNEL_SRC=$(KERNEL_PATH) O=$(KOUTDIR) ENABLE_IRQ=yes \
		-C $(PKGDIR)/linux/isp_vvcam_module/vvcam/v4l2 $(LOG_MUTE)
	$(MAKE) KERNEL_SRC=$(KERNEL_PATH) O=$(KOUTDIR) ENABLE_IRQ=yes modules_install \
		-C $(PKGDIR)/linux/isp_vvcam_module/vvcam/v4l2 $(LOG_MUTE)
	$(call fbprint_d,"isp_vvcam_module")

# Copyright 2021-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# Kernel loadable module verisilicon ISP vvcam v4l2

# isp_vvcam_module/vvcam/readme_v4l2.txt


isp_vvcam_module:
	@[ $(SOCFAMILY) != IMX ] && exit || \
	 $(call download_repo,isp_vvcam_module,linux) && \
	 $(call download_repo,linux,linux) && \
	 \
	 if [ ! -d $(FBOUTDIR)/linux/kernel/$(DESTARCH)/$(SOCFAMILY) ]; then \
	     bld linux -m $(MACHINE); \
	 fi && \
	 opdir=$(KERNEL_OUTPUT_PATH)/$(KERNEL_BRANCH) && mkdir -p $$opdir && \
	 \
	 cd $(PKGDIR)/linux/isp_vvcam_module/vvcam/v4l2 && \
	 $(call fbprint_b,"isp_vvcam_module") && \
	 export INSTALL_MOD_PATH=$$opdir/tmp && \
	 $(MAKE) KERNEL_SRC=$(KERNEL_PATH) O=$$opdir ENABLE_IRQ=yes $(LOG_MUTE) && \
	 $(MAKE) KERNEL_SRC=$(KERNEL_PATH) O=$$opdir ENABLE_IRQ=yes modules_install $(LOG_MUTE) && \
	 $(call fbprint_d,"isp_vvcam_module")

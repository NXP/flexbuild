# Copyright 2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# Kernel loadable module verisilicon ISP vvcam v4l2

# isp_vvcam_module/vvcam/readme_v4l2.txt


isp_vvcam_module:
ifeq ($(CONFIG_ISP_VVCAM_MODULE), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(SOCFAMILY) != IMX ] && exit || true && \
	 $(call repo-mngr,fetch,isp_vvcam_module,linux) && \
	 $(call repo-mngr,fetch,$(KERNEL_TREE),linux) && \
	 \
	 if [ ! -d $(FBOUTDIR)/linux/kernel/$(DESTARCH)/$(SOCFAMILY) ]; then \
	     bld -c linux -a $(DESTARCH) -p $(SOCFAMILY) -f $(CFGLISTYML); \
	 fi && \
	 curbrch=`cd $(KERNEL_PATH) && git branch | grep ^* | cut -d' ' -f2` && \
	 opdir=$(KERNEL_OUTPUT_PATH)/$$curbrch && mkdir -p $$opdir && \
	 \
	 cd $(PKGDIR)/linux/isp_vvcam_module/vvcam/v4l2 && \
	 $(call fbprint_b,"isp_vvcam_module") && \
	 export INSTALL_MOD_PATH=$$opdir/tmp && \
	 make KERNEL_SRC=$(KERNEL_PATH) O=$$opdir clean && \
	 make KERNEL_SRC=$(KERNEL_PATH) O=$$opdir ENABLE_IRQ=yes && \
	 make KERNEL_SRC=$(KERNEL_PATH) O=$$opdir ENABLE_IRQ=yes modules_install && \
	 $(call fbprint_d,"isp_vvcam_module")
endif
endif

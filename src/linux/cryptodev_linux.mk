# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


cryptodev_linux:
ifeq ($(CONFIG_CRYPTODEV_LINUX), "y")
	@[ "$(BUILDARG)" = custom ] && exit || \
	 $(call repo-mngr,fetch,cryptodev_linux,linux) && \
	 $(call repo-mngr,fetch,linux,linux) && \
	 cd $(PKGDIR)/linux/cryptodev_linux && \
	 if [ ! -d $(FBOUTDIR)/linux/kernel/$(DESTARCH)/$(SOCFAMILY) ]; then \
	     bld -c linux -a $(DESTARCH) -p $(SOCFAMILY) -f $(CFGLISTYML); \
	 fi && \
	 curbrch=`cd $(KERNEL_PATH) && git branch | grep ^* | cut -d' ' -f2` && \
	 opdir=$(KERNEL_OUTPUT_PATH)/$$curbrch && \
	 cd $(PKGDIR)/linux/cryptodev_linux && \
	 $(call fbprint_b,"cryptodev_linux") && \
	 export KERNEL_MAKE_OPTS="-lcrypto -L$(RFSDIR)/usr/lib/aarch64-linux-gnu" && \
	 $(MAKE) clean KERNEL_DIR=$(KERNEL_PATH) O=$$opdir && \
	 $(MAKE) KERNEL_DIR=$(KERNEL_PATH) O=$$opdir && \
	 $(MAKE) install KERNEL_DIR=$(KERNEL_PATH) O=$$opdir INSTALL_MOD_PATH=$$opdir/tmp && \
	 $(call fbprint_d,"cryptodev_linux")
endif

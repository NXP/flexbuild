# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


cryptodev_linux:
	@[ "$(BUILDARG)" = custom ] && exit || \
	 $(call repo-mngr,fetch,cryptodev_linux,linux) && \
	 $(call repo-mngr,fetch,linux,linux) && \
	 $(call fbprint_b,"cryptodev_linux") && \
	 curbrch=`cd $(KERNEL_PATH) && git branch | grep ^* | cut -d' ' -f2` && \
         opdir=$(KERNEL_OUTPUT_PATH)/$$curbrch && \
	 if [ ! -f $$opdir/include/config/auto.conf ]; then \
	     bld linux -a $(DESTARCH) -p $(SOCFAMILY) -f $(CFGLISTYML); \
	 fi && \
	 \
	 cd $(PKGDIR)/linux/cryptodev_linux && \
	 export KERNEL_MAKE_OPTS="-lcrypto -L$(RFSDIR)/usr/lib/aarch64-linux-gnu" && \
	 $(MAKE) KERNEL_DIR=$(KERNEL_PATH) O=$$opdir && \
	 $(MAKE) install KERNEL_DIR=$(KERNEL_PATH) O=$$opdir INSTALL_MOD_PATH=$$opdir/tmp && \
	 $(call fbprint_d,"cryptodev_linux")

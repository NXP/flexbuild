# Copyright 2017-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


cryptodev_linux:
	@[ "$(BUILDARG)" = custom ] && exit || \
	 $(call download_repo,linux,linux) && \
	 $(call download_repo,cryptodev_linux,linux) && \
	 opdir=$(KERNEL_OUTPUT_PATH)/$(KERNEL_BRANCH) && \
	 if [ ! -f $$opdir/include/config/auto.conf ]; then \
	     bld linux -m $(MACHINE); \
	 fi && \
	 \
	 cd $(PKGDIR)/linux/cryptodev_linux && \
	 $(call fbprint_b,"cryptodev_linux") && \
	 $(call patch_apply,cryptodev_linux,linux) && \
	 export KERNEL_MAKE_OPTS="-lcrypto" && \
	 $(MAKE) KERNEL_DIR=$(KERNEL_PATH) O=$$opdir -j$(JOBS) $(LOG_MUTE) && \
	 $(MAKE) install KERNEL_DIR=$(KERNEL_PATH) O=$$opdir INSTALL_MOD_PATH=$$opdir/tmp -j$(JOBS) $(LOG_MUTE) && \
	 $(call fbprint_d,"cryptodev_linux")

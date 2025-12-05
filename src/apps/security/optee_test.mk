# Copyright 2017-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



optee_test: optee_client optee_os
ifeq ($(CONFIG_OPTEE),y)
	@[ $(DESTARCH) != arm64  ] && exit || \
	 $(call download_repo,optee_test,apps/security) && \
	 $(call patch_apply,optee_test,apps/security) && \
	 \
	 $(call fbprint_b,"optee_test") && \
	 if [ $(SOCFAMILY) = "IMX" ]; then \
		socfamily=imx; \
	 else \
		socfamily=ls; \
	 fi && \
	 cd $(SECDIR)/optee_test && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 $(MAKE) CFG_ARM64=y OPTEE_CLIENT_EXPORT=$(DESTDIR)/usr \
	         TA_DEV_KIT_DIR=$(SECDIR)/optee_os/out/arm-plat-"$$socfamily"/export-ta_arm64 $(LOG_MUTE) && \
	 mkdir -p $(DESTDIR)/usr/lib/optee_armtz && \
	 cp $(SECDIR)/optee_test/out/ta/*/*.ta $(DESTDIR)/usr/lib/optee_armtz && \
	 cp $(SECDIR)/optee_test/out/xtest/xtest $(DESTDIR)/usr/bin && \
	 mkdir -p $(DESTDIR)/usr/lib/tee-supplicant/plugins && \
	 cp $(SECDIR)/optee_test/out/supp_plugin/*.plugin $(DESTDIR)/usr/lib/tee-supplicant/plugins/ && \
	 $(call fbprint_d,"optee_test")
endif

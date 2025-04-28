# Copyright 2017-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



optee_test:
ifeq ($(CONFIG_OPTEE),y)
	@[ $(DESTARCH) != arm64 -o $(DISTROVARIANT) = tiny -o $(DISTROVARIANT) = base ] && exit || \
	 $(call repo-mngr,fetch,optee_test,apps/security) && \
	 if [ ! -f $(DESTDIR)/usr/lib/libteec.so.1.0 ]; then \
	     CONFIG_OPTEE=y bld optee_client -m $(MACHINE); \
	 fi && \
	 if [ ! -d $(SECDIR)/optee_os/out/arm-plat-ls/export-ta_arm64 ]; then \
	     CONFIG_OPTEE=y bld optee_os -m ls1028ardb -r $(DISTROTYPE):$(DISTROVARIANT); \
	 fi && \
	 \
	 $(call fbprint_b,"optee_test") && \
	 cd $(SECDIR)/optee_test && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 $(MAKE) CFG_ARM64=y OPTEE_CLIENT_EXPORT=$(DESTDIR)/usr \
	         TA_DEV_KIT_DIR=$(SECDIR)/optee_os/out/arm-plat-ls/export-ta_arm64 $(LOG_MUTE) && \
	 mkdir -p $(DESTDIR)/usr/lib/optee_armtz && \
	 cp $(SECDIR)/optee_test/out/ta/*/*.ta $(DESTDIR)/usr/lib/optee_armtz && \
	 cp $(SECDIR)/optee_test/out/xtest/xtest $(DESTDIR)/usr/bin && \
	 mkdir -p $(DESTDIR)/usr/lib/tee-supplicant/plugins && \
	 cp $(SECDIR)/optee_test/out/supp_plugin/*.plugin $(DESTDIR)/usr/lib/tee-supplicant/plugins/ && \
	 $(call fbprint_d,"optee_test")
endif

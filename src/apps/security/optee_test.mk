# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



optee_test:
ifeq ($(CONFIG_OPTEE), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = tiny -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"optee_test") && \
	 $(call repo-mngr,fetch,optee_test,apps/security) && \
	 if [ ! -f $(DESTDIR)/lib/libteec.so.1.0 ]; then \
	     bld -c optee_client -m $(MACHINE); \
	 fi && \
	 if [ ! -d $(SECDIR)/optee_os/out/arm-plat-ls/export-ta_arm64 ]; then \
	     bld -c optee_os -m ls1028ardb -r $(DISTROTYPE):$(DISTROSCALE) -f $(CFGLISTYML); \
	 fi && \
	 cd $(SECDIR)/optee_test && \
	 export CC=${CROSS_COMPILE}gcc && \
	 $(MAKE) CFG_ARM64=y OPTEE_CLIENT_EXPORT=$(DESTDIR)/usr \
	         TA_DEV_KIT_DIR=$(SECDIR)/optee_os/out/arm-plat-ls/export-ta_arm64 && \
	 mkdir -p $(DESTDIR)/usr/lib/optee_armtz && \
	 cp $(SECDIR)/optee_test/out/ta/*/*.ta $(DESTDIR)/usr/lib/optee_armtz && \
	 cp $(SECDIR)/optee_test/out/xtest/xtest $(DESTDIR)/usr/bin && \
	 mkdir -p $(DESTDIR)/usr/lib/tee-supplicant/plugins && \
	 cp $(SECDIR)/optee_test/out/supp_plugin/*.plugin $(DESTDIR)/usr/lib/tee-supplicant/plugins/ && \
	 $(call fbprint_d,"optee_test")
endif
else
	@$(call fbprint_w,INFO: OPTEE is not enabled by default)
endif

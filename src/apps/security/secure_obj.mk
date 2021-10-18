# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



secure_obj:
ifneq ($(CONFIG_SECURE_OBJ)$(FORCE), "n")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = tiny -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"secure_obj") && \
	 $(call repo-mngr,fetch,secure_obj,apps/security) && \
	 if [ ! -f $(DESTDIR)/usr/local/include/openssl/opensslconf.h ]; then \
	     bld -c openssl -r $(DISTROTYPE):$(DISTROSCALE) -f $(CFGLISTYML); \
	 fi && \
	 if [ $(CONFIG_OPTEE) != y ]; then \
	     $(call fbprint_e,"Please enable CONFIG_OPTEE to y in configs/$(CFGLISTYML)"); exit 1; \
	 fi && \
	 if [ ! -d $(SECDIR)/optee_os/out/arm-plat-ls ]; then \
	     bld -c optee_os -m ls1028ardb -r $(DISTROTYPE):$(DISTROSCALE) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -f $(DESTDIR)/lib/libteec.so ]; then \
	     bld -c optee_client -r $(DISTROTYPE):$(DISTROSCALE) -f $(CFGLISTYML); \
	 fi && \
	 curbrch=`cd $(KERNEL_PATH) && git branch | grep ^* | cut -d' ' -f2` && \
	 kerneloutdir=$(KERNEL_OUTPUT_PATH)/$$curbrch && \
	 mkdir -p $(DESTDIR)/usr/lib && \
	 if [ ! -f $$kerneloutdir/.config ]; then \
	     bld -c linux -a $(DESTARCH) -p $(SOCFAMILY) -f $(CFGLISTYML); \
	 fi && \
	 kernelrelease=`cat $$kerneloutdir/include/config/kernel.release` && \
	 cd $(SECDIR)/secure_obj && \
	 export DESTDIR=${DESTDIR}/usr/local && \
	 export TA_DEV_KIT_DIR=$(SECDIR)/optee_os/out/arm-plat-ls/export-ta_arm64 && \
	 export OPTEE_CLIENT_EXPORT=$(DESTDIR)/usr && \
	 export KERNEL_SRC=$(KERNEL_PATH) && \
	 export KERNEL_BUILD=$$kerneloutdir && \
	 export INSTALL_MOD_PATH=$$kerneloutdir/tmp && \
	 $(call fbprint_n,"Using KERNEL_BUILD $$kerneloutdir") && \
	 export SECURE_STORAGE_PATH=$(SECDIR)/secure_obj/secure_storage_ta/ta && \
	 export OPENSSL_PATH=$(SECDIR)/openssl && \
	 mkdir -p $(DESTDIR)/usr/local/secure_obj/$$curbrch && \
	 mkdir -p $(DESTDIR)/usr/lib/aarch64-linux-gnu/openssl-1.0.0/engines && \
	 mkdir -p $(DESTDIR)/lib/optee_armtz && \
	 ./compile.sh && \
	 cp images/libeng_secure_obj.so $(DESTDIR)/usr/lib/aarch64-linux-gnu/openssl-1.0.0/engines && \
	 mkdir -p $(KERNEL_OUTPUT_PATH)/$$curbrch/tmp/lib/modules/$$kernelrelease/extra && \
	 cp images/*.ta $(DESTDIR)/lib/optee_armtz && \
	 cp images/*.so $(DESTDIR)/usr/local/lib && \
	 cp images/{*_app,mp_verify} $(DESTDIR)/usr/local/bin && \
	 cp -rf securekey_lib/include/* $(DESTDIR)/usr/local/include && \
	 $(call fbprint_d,"secure_obj")
endif
else
	@$(call fbprint_w,INFO: SECURE_OBJ is not enabled by default in configs/$(CFGLISTYML)) && exit
endif

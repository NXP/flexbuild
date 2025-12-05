# Copyright 2017-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# libssl-dev for opensslconf.h

#secure_obj:
secure_obj: optee_os optee_client
	@[ $(DESTARCH) != arm64  ] && exit || \
	 $(call download_repo,secure_obj,apps/security) && \
	 $(call patch_apply,secure_obj,apps/security) && \
	 $(call fbprint_b,"secure_obj") && \
	 if [ "$(CONFIG_OPTEE)" != "y" ]; then \
	     $(call fbprint_d,"secure_obj"); exit ; \
	 fi && \
	 kerneloutdir=$(KERNEL_OUTPUT_PATH)/$(KERNEL_BRANCH) && \
	 mkdir -p $(DESTDIR)/usr/lib && \
	 kernelrelease=`cat $$kerneloutdir/include/config/kernel.release` && \
	 if [ $(SOCFAMILY) = "IMX" ]; then \
		 socfamily=imx; \
	 else \
		 socfamily=ls; \
	 fi && \
	 \
	 cd $(SECDIR)/secure_obj && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export DESTDIR=${DESTDIR}/usr/local && \
	 export TA_DEV_KIT_DIR=$(SECDIR)/optee_os/out/arm-plat-"$$socfamily"/export-ta_arm64 && \
	 export OPTEE_CLIENT_EXPORT=$(DESTDIR)/usr && \
	 export KERNEL_SRC=$(KERNEL_PATH) && \
	 export KERNEL_BUILD=$$kerneloutdir && \
	 export INSTALL_MOD_PATH=$$kerneloutdir/tmp && \
	 export SECURE_STORAGE_PATH=$(SECDIR)/secure_obj/secure_storage_ta/ta && \
	 export OPENSSL_PATH=$(SECDIR)/openssl && \
	 mkdir -p $(DESTDIR)/usr/local/secure_obj/$(KERNEL_BRANCH) && \
	 mkdir -p $(DESTDIR)/usr/lib/aarch64-linux-gnu/openssl-1.0.0/engines && \
	 mkdir -p $(DESTDIR)/usr/lib/optee_armtz && \
	 sed -i 's/^CC/#CC/' secure_obj-openssl-engine/Makefile && \
	 sed -e 's/^CC/#CC/' -e 's/^AR/#AR/' -e 's/^LD/#LD/' -i securekey_lib/flags.mk && \
	 ./compile.sh $(LOG_MUTE) && \
	 cp images/libeng_secure_obj.so $(DESTDIR)/usr/lib/aarch64-linux-gnu/openssl-1.0.0/engines && \
	 mkdir -p $(KERNEL_OUTPUT_PATH)/$(KERNEL_BRANCH)/tmp/lib/modules/$$kernelrelease/extra && \
	 cp images/*.ta $(DESTDIR)/usr/lib/optee_armtz && \
	 cp images/*.so $(DESTDIR)/usr/local/lib && \
	 cp images/{*_app,mp_verify} $(DESTDIR)/usr/local/bin && \
	 cp -rf securekey_lib/include/* $(DESTDIR)/usr/local/include && \
	 $(call fbprint_d,"secure_obj")

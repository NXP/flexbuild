# Copyright 2017-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# libssl-dev for opensslconf.h

secure_obj:
	@[ $(DESTARCH) != arm64 -o $(DISTROVARIANT) = tiny -o $(DISTROVARIANT) = base ] && exit || \
	 $(call fbprint_b,"secure_obj") && \
	 $(call repo-mngr,fetch,secure_obj,apps/security) && \
	 if [ "$(CONFIG_OPTEE)" != "y" ]; then \
	     $(call fbprint_d,"secure_obj"); exit ; \
	 fi && \
	 if [ ! -d $(SECDIR)/optee_os/out/arm-plat-ls ]; then \
	     CONFIG_OPTEE=y bld optee_os -m ls1028ardb -r $(DISTROTYPE):$(DISTROVARIANT); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/libteec.so ]; then \
	     CONFIG_OPTEE=y bld optee_client -r $(DISTROTYPE):$(DISTROVARIANT); \
	 fi && \
	 curbrch=`cd $(KERNEL_PATH) && git branch | grep ^* | cut -d' ' -f2` && \
	 kerneloutdir=$(KERNEL_OUTPUT_PATH)/$$curbrch && \
	 mkdir -p $(DESTDIR)/usr/lib && \
	 if [ ! -f $$kerneloutdir/.config ]; then \
	     bld linux -a $(DESTARCH) -p $(SOCFAMILY); \
	 fi && \
	 kernelrelease=`cat $$kerneloutdir/include/config/kernel.release` && \
	 \
	 cd $(SECDIR)/secure_obj && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
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
	 mkdir -p $(DESTDIR)/usr/lib/optee_armtz && \
	 sed -i 's/^CC/#CC/' secure_obj-openssl-engine/Makefile && \
	 sed -e 's/^CC/#CC/' -e 's/^AR/#AR/' -e 's/^LD/#LD/' -i securekey_lib/flags.mk && \
	 ./compile.sh && \
	 cp images/libeng_secure_obj.so $(DESTDIR)/usr/lib/aarch64-linux-gnu/openssl-1.0.0/engines && \
	 mkdir -p $(KERNEL_OUTPUT_PATH)/$$curbrch/tmp/lib/modules/$$kernelrelease/extra && \
	 cp images/*.ta $(DESTDIR)/usr/lib/optee_armtz && \
	 cp images/*.so $(DESTDIR)/usr/local/lib && \
	 cp images/{*_app,mp_verify} $(DESTDIR)/usr/local/bin && \
	 cp -rf securekey_lib/include/* $(DESTDIR)/usr/local/include && \
	 $(call fbprint_d,"secure_obj")

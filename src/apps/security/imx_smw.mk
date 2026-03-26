# Copyright 2024,2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# NXP i.MX Security Middleware Library


#imx_smw:
imx_smw: optee_client optee_os
	@$(call download_repo,imx_smw,apps/security)
	 $(call patch_apply,imx_smw,apps/security)
	 $(call fbprint_b,"imx_smw")
	 cd $(SECDIR)/imx_smw
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)"
	 mkdir -p build_$(DISTROTYPE)_$(ARCH)
	 cmake  -S $(SECDIR)/imx_smw \
		-B build_$(DISTROTYPE)_$(ARCH) \
		-DCMAKE_BUILD_TYPE=release \
		-DTA_DEV_KIT_ROOT=$(SECDIR)/optee_os/out/arm-plat-imx/export-ta_arm64 \
		-DTA_DEV_KIT_INCLUDE_DIR=$(SECDIR)/optee_os/out/arm-plat-imx/export-ta_arm64/include \
		-DTA_DEV_KIT_MK_DIR=$(SECDIR)/optee_os/out/arm-plat-imx/export-ta_arm64/mk \
		-DTA_HOST_INCLUDE_DIR=$(SECDIR)/optee_os/out/arm-plat-imx/export-ta_arm64/host_include \
		-DTEEC_ROOT=$(RFSDIR) \
		-DJSONC_ROOT=$(RFSDIR)/usr \
		-DJSONC_INCLUDE_DIR=$(RFSDIR)/usr/include/json-c \
		-DSQLite_DIR=$(RFSDIR)/usr \
		-DSQLite3_INCLUDE_DIR=$(RFSDIR)/usr/include \
		-DSQLite3_LIBRARY=$(RFSDIR)/usr/lib/aarch64-linux-gnu/libsqlite3.so \
		-DTEEC_INCLUDE_DIR=$(DESTDIR)/usr/include \
		-DTEEC_LIBRARY=$(DESTDIR)/usr/lib/libteec.so \
		-DCMAKE_POLICY_DEFAULT_CMP0144=NEW \
		-DTEE_TA_DESTDIR=$(DESTDIR)/usr/lib $(LOG_MUTE)
	 cmake --build build_$(DISTROTYPE)_$(ARCH) -j1 --target all $(LOG_MUTE)
	 cmake --install build_$(DISTROTYPE)_$(ARCH) --prefix /usr $(LOG_MUTE)
	 $(call fbprint_d,"imx_smw")

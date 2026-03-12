# Copyright 2024,2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# OpenSSL Provider for NXP EdgeLock secure element SE05X (SE050_C, SE051_E)

# An OpenSSL provider for NXP EdgeLock SE05x secure element product family

# generates libsssProvider.so


SE05_APPLET         ?= "SE05X_C"
SE05_APPLET_VERSION ?= "07_02"
SE05_APPLET_AUTH    ?= "None"


openssl_provider_se05x:
	@$(call download_repo,openssl_provider_se05x,apps/security,submod) && \
	 $(call patch_apply,openssl_provider_se05x,apps/security) && \
	 $(call fbprint_b,"openssl_provider_se05x") && \
	 cd $(SECDIR)/openssl_provider_se05x && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 mkdir -p build_$(DISTROTYPE)_$(ARCH) && \
	 cmake  -S $(SECDIR)/openssl_provider_se05x \
		-B build_$(DISTROTYPE)_$(ARCH) \
		-DCMAKE_BUILD_TYPE=release \
		-DCMAKE_C_FLAGS="-I$(DESTDIR)/usr/include -I$(RFSDIR)/usr/include" \
		-DPTMW_Applet=$(SE05_APPLET) \
		-DPTMW_SE05X_Ver=$(SE05_APPLET_VERSION) \
		-DPTMW_SE05X_Auth=$(SE05_APPLET_AUTH) \
		-DPTMW_HostCrypto=OPENSSL $(LOG_MUTE) && \
	 cmake --build build_$(DISTROTYPE)_$(ARCH) --target all $(LOG_MUTE) && \
	 cmake --install build_$(DISTROTYPE)_$(ARCH) --prefix /usr $(LOG_MUTE) && \
	 $(call fbprint_d,"openssl_provider_se05x")

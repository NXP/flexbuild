# Copyright 2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# OpenSSL Provider for NXP EdgeLock secure element SE05X (SE050_C, SE051_E)

# An OpenSSL provider for NXP EdgeLock SE05x secure element product family

# generates libsssProvider.so


APPLET         ?= "SE05X_C"
APPLET_VERSION ?= "07_02"
APPLET_AUTH    ?= "None"


openssl_provider_se05x:
	@[ $(SOCFAMILY) != IMX -o $(DISTROVARIANT) = base -o $(DISTROVARIANT) = tiny ] && exit || \
	 $(call fbprint_b,"openssl_provider_se05x") && \
	 $(call repo-mngr,fetch,openssl_provider_se05x,apps/security) && \
	 cd $(SECDIR)/openssl_provider_se05x && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 mkdir -p build_$(DISTROTYPE)_$(ARCH) && \
	 cmake  -S $(SECDIR)/openssl_provider_se05x \
		-B build_$(DISTROTYPE)_$(ARCH) \
		-DCMAKE_BUILD_TYPE=release \
		-DCMAKE_C_FLAGS="-I$(DESTDIR)/usr/include -I$(RFSDIR)/usr/include" \
		-DPTMW_Applet=$(APPLET) \
		-DPTMW_SE05X_Ver=$(APPLET_VERSION) \
		-DPTMW_SE05X_Auth=$(APPLET_AUTH) \
		-DPTMW_HostCrypto=OPENSSL && \
	 cmake --build build_$(DISTROTYPE)_$(ARCH) --target all && \
	 cmake --install build_$(DISTROTYPE)_$(ARCH) --prefix /usr && \
	 $(call fbprint_d,"openssl_provider_se05x")

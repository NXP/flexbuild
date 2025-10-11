# Copyright 2025 NXP
#
# SPDX-License-Identifier: BSD-3-Clause





#imx_secure_enclave:
imx_secure_enclave: openssl mbedtls
	@[ $${MACHINE:0:4} != imx9 ] && exit || \
	$(call download_repo,imx_secure_enclave,apps/security,git) && \
	$(call patch_apply,imx_secure_enclave,apps/security) && \
	\
	$(call fbprint_b,"imx_secure_enclave") && \
	cd $(SECDIR)/imx_secure_enclave && \
	export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)" && \
	export AR="$(CROSS_COMPILE)ar" && \
	export RANLIB="${CROSS_COMPILE}ranlib" && \
	export CFLAGS="-O2 -I$(DESTDIR)/usr/include -I$(RFSDIR)/usr/include $(EXTRA_CFLAGS)" && \
	export LDFLAGS="-L$(DESTDIR)/usr/lib -L$(RFSDIR)/usr/lib $(EXTRA_LDFLAGS)" && \
	$(MAKE) PLAT=ele clean; make clean && \
	if [[ "$${MACHINE:0:5}" == "imx95" || "$${MACHINE:0:5}" == "imx94" ]]; then \
		$(MAKE) -j$(JOBS) \
			SYSTEMD_DIR=/usr/lib/systemd/system \
			OPENSSL_PATH=$(SECDIR)/openssl \
			MBEDTLS_PATH=$(SECDIR)/mbedtls \
			LDFLAGS="-L$(DESTDIR)/usr/lib" \
			DESTDIR=$(DESTDIR) \
			install_tests $(LOG_MUTE); \
	fi && \
	make clean && \
	$(MAKE) -j$(JOBS) PLAT=ele \
		SYSTEMD_DIR=/usr/lib/systemd/system \
		OPENSSL_PATH=$(SECDIR)/openssl \
		MBEDTLS_PATH=$(SECDIR)/mbedtls \
		LDFLAGS="-L$(DESTDIR)/usr/lib" \
		DESTDIR=$(DESTDIR) \
		install_tests $(LOG_MUTE) && \
	$(call fbprint_d,"imx_secure_enclave")

# Copyright 2017-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause




openssl:
	 @$(call download_repo,openssl,apps/security,submod) && \
	 $(call patch_apply,openssl,apps/security) && \
	 if [ ! -d $(DESTDIR)/usr/local/include/crypto ]; then \
	     bld cryptodev_linux -m $(MACHINE); \
	 fi && \
	 $(call fbprint_b,"OpenSSL") && \
	 cd $(SECDIR)/openssl && \
	 ./Configure enable-devcryptoeng linux-aarch64 shared \
		     -I$(DESTDIR)/usr/include -I$(PKGDIR)/linux/cryptodev_linux \
		     --prefix=/usr \
		     --openssldir=lib/ssl $(LOG_MUTE) && \
	 $(MAKE) -j$(JOBS) depend $(LOG_MUTE) && \
	 $(MAKE) -j$(JOBS) $(LOG_MUTE) && \
	 $(MAKE) -j$(JOBS) install DESTDIR=$(DESTDIR) MANSUFFIX=ssl $(LOG_MUTE) && \
	 mkdir -p $(DESTDIR)/usr/local/bin && \
	 mv $(DESTDIR)/usr/bin/openssl $(DESTDIR)/usr/local/bin && \
	 rm -rf $(DESTDIR)/usr/lib/ssl/certs && \
	 rm -rf $(DESTDIR)/usr/lib/ssl/private && \
	 ln -sf engines-3/devcrypto.so $(DESTDIR)/usr/lib/libcryptodev.so && \
	 $(call fbprint_d,"OpenSSL")

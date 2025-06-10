# Copyright 2017-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause




openssl:
	@[ $(DISTROVARIANT) = base -o $(DISTROVARIANT) = tiny ] && exit || \
	 $(call repo-mngr,fetch,openssl,apps/security) && \
	 if [ ! -d $(DESTDIR)/usr/local/include/crypto ]; then \
	     bld cryptodev_linux -a $(DESTARCH) -p $(SOCFAMILY); \
	 fi && \
	 $(call fbprint_b,"OpenSSL") && \
	 cd $(SECDIR)/openssl && \
	 if [ -d $(FBDIR)/patch/openssl ] && [ ! -f .patchdone ]; then \
	     git am $(FBDIR)/patch/openssl/*.patch $(LOG_MUTE) && touch .patchdone; \
	 fi && \
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

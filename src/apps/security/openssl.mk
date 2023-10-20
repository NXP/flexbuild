# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause




openssl:
ifeq ($(CONFIG_OPENSSL),y)
	@[ $(DISTROVARIANT) = base -o $(DISTROVARIANT) = tiny -o $(DESTARCH) != arm64 ] && exit || \
	 $(call fbprint_b,"OpenSSL") && \
	 $(call repo-mngr,fetch,openssl,apps/security) && \
	 if [ ! -d $(DESTDIR)/usr/local/include/crypto ]; then \
	     bld cryptodev_linux -a $(DESTARCH) -r $(DISTROTYPE):$(DISTROVARIANT) -p $(SOCFAMILY) -f $(CFGLISTYML); \
	 fi && \
	 cd $(SECDIR)/openssl && \
	 if [ ! -f .patchdone ]; then \
	    git am $(FBDIR)/src/apps/security/patch/openssl/*.patch && touch .patchdone; \
	 fi && \
	 ./Configure enable-devcryptoeng linux-aarch64 shared \
		     -I$(DESTDIR)/usr/include -I$(PKGDIR)/linux/cryptodev_linux \
		     --prefix=/usr \
		     --openssldir=lib/ssl && \
	 $(MAKE) -j$(JOBS) depend && \
	 $(MAKE) -j$(JOBS) 1>/dev/null && \
	 $(MAKE) -j$(JOBS) install DESTDIR=$(DESTDIR) MANSUFFIX=ssl 1>/dev/null && \
	 rm -fr $(DESTDIR)/usr/lib/ssl/{certs,openssl.cnf,private} && \
	 ln -s /etc/ssl/certs $(DESTDIR)/usr/lib/ssl/certs && \
	 ln -s /etc/ssl/private $(DESTDIR)/usr/lib/ssl/private && \
	 ln -s /etc/ssl/openssl.cnf $(DESTDIR)/usr/lib/ssl/openssl.cnf && \
	 $(call fbprint_d,"OpenSSL")
endif

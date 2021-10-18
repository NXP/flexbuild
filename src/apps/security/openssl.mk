# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause




openssl:
ifeq ($(CONFIG_OPENSSL), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -a $(DISTROTYPE) != debian -a $(DISTROTYPE) != yocto -o \
	   $(DISTROSCALE) = lite -o $(DISTROSCALE) = tiny ] && exit || \
	 $(call fbprint_b,"OpenSSL") && \
	 $(call repo-mngr,fetch,openssl,apps/security) && \
	 if [ ! -d $(DESTDIR)/usr/local/include/crypto ]; then \
	     bld -c cryptodev_linux -a $(DESTARCH) -r $(DISTROTYPE):$(DISTROSCALE) -p $(SOCFAMILY) -f $(CFGLISTYML); \
	 fi && \
	 cd $(SECDIR)/openssl && \
	 ./Configure enable-devcryptoeng linux-aarch64 shared \
		     -I$(DESTDIR)/usr/local/include \
		     --prefix=/usr/local \
		     --openssldir=lib/ssl && \
	 $(MAKE) depend && \
	 $(MAKE) 1>/dev/null && \
	 $(MAKE) install DESTDIR=$(DESTDIR) 1>/dev/null && \
	 rm -fr $(DESTDIR)/usr/local/lib/ssl/{certs,openssl.cnf,private} && \
	 ln -s /etc/ssl/certs/ $(DESTDIR)/usr/local/lib/ssl/ && \
	 ln -s /etc/ssl/private/ $(DESTDIR)/usr/local/lib/ssl/ && \
	 ln -s /etc/ssl/openssl.cnf $(DESTDIR)/usr/local/lib/ssl/ && \
	 $(call fbprint_d,"OpenSSL")
endif
endif

# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



libpkcs11:
	@[ $(DESTARCH) != arm64 -o $(DISTROVARIANT) = base -o $(DISTROVARIANT) = tiny ] && exit || \
	 $(call fbprint_b,"libpkcs11") && \
	 $(call repo-mngr,fetch,libpkcs11,apps/security) && \
	 if [ ! -d $(SECDIR)/secure_obj/securekey_lib/include ]; then \
	     bld secure_obj -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH) -p $(SOCFAMILY); \
	 fi && \
	 cd $(SECDIR)/libpkcs11 && \
	 sed -e 's/^CC/#CC/' -e 's/^LD/#LD/' -e 's/s -Werror/s/' -i flags.mk && \
	 sed -i 's/-g -Iinclude/-g -fcommon -Iinclude/' Makefile && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export LDFLAGS="-L$(RFSDIR)/usr/lib -L$(RFSDIR)/usr/lib/aarch64-linux-gnu" && \
	 $(MAKE) clean && \
	 $(MAKE) all OPENSSL_PATH=$(SECDIR)/openssl \
	 EXPORT_DIR=$(DESTDIR)/usr/local CURDIR=$(SECDIR)/libpkcs11 \
	 SECURE_OBJ_PATH=$(SECDIR)/secure_obj/securekey_lib && \
	 mkdir -p $(DESTDIR)/usr/local/bin && \
	 mv $(DESTDIR)/usr/local/app/pkcs11_app $(DESTDIR)/usr/local/bin && \
	 cp -f images/thread_test $(DESTDIR)/usr/local/bin && \
	 $(call fbprint_d,"libpkcs11")

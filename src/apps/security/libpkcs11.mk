# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



libpkcs11:
ifneq ($(CONFIG_LIBPKCS11)$(FORCE), "n")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = lite -o $(DISTROSCALE) = tiny ] && exit || \
	 $(call fbprint_b,"libpkcs11") && \
	 $(call repo-mngr,fetch,libpkcs11,apps/security) && \
	 if [ ! -f $(SECDIR)/openssl/Configure ]; then \
	     bld -c openssl -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -d $(SECDIR)/secure_obj/securekey_lib/include ]; then \
	     bld -c secure_obj -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 cd $(SECDIR)/libpkcs11 && \
	 sed -i 's/s -Werror/s/' flags.mk && \
	 $(MAKE) clean && \
	 $(MAKE) all OPENSSL_PATH=$(SECDIR)/openssl \
	 EXPORT_DIR=$(DESTDIR)/usr/local CURDIR=$(SECDIR)/libpkcs11 \
	 SECURE_OBJ_PATH=$(SECDIR)/secure_obj/securekey_lib && \
	 mkdir -p $(DESTDIR)/usr/local/bin && \
	 mv $(DESTDIR)/usr/local/app/pkcs11_app $(DESTDIR)/usr/local/bin && \
	 cp -f images/thread_test $(DESTDIR)/usr/bin && \
	 $(call fbprint_d,"libpkcs11")
endif
else
	@$(call fbprint_w,INFO: LIBPKCS11 is not enabled by default in configs/$(CFGLISTYML)) && exit
endif

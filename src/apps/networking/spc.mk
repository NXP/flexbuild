# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


spc:
ifeq ($(CONFIG_SPC), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(SOCFAMILY) != LS -a $(DISTROSCALE) = desktop -o $(DISTROSCALE) = lite -o \
	   $(DISTROTYPE) = centos -o $(DISTROSCALE) = tiny ] && exit || \
	 $(call repo-mngr,fetch,spc,apps/networking) && \
	 if [ $(DISTROTYPE) = ubuntu -o $(DISTROTYPE) = yocto -o $(DISTROTYPE) = debian ]; then \
	     xmlhdr=$(RFSDIR)/usr/include/libxml2; \
	 elif [ $(DISTROTYPE) = buildroot ]; then \
	     xmlhdr=$(RFSDIR)/../host/include/libxml2; \
	 fi && \
	 if [ ! -f $$xmlhdr/libxml/parser.h ]; then \
	     bld -i mkrfs -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 export LDFLAGS="-L$(RFSDIR)/usr/lib -Wl,-rpath=$(RFSDIR)/usr/lib:$(RFSDIR)/usr/lib/aarch64-linux-gnu" && \
	 $(MAKE) -C $(NETDIR)/spc/source \
		 LIBXML2_HEADER_PATH=$$xmlhdr \
		 TCLAP_HEADER_PATH=$(RFSDIR)/usr/include \
		 NET_USPACE_HEADER_PATH=$(NETDIR)/spc/source/include/net \
		 CXX=$(CROSS_COMPILE)g++ \
		 CC=$(CROSS_COMPILE)gcc && \
	 cp -rf $(NETDIR)/spc/source/spc $(DESTDIR)/usr/local/bin && \
	 cp -rf $(NETDIR)/spc/etc $(DESTDIR) && \
	 $(call fbprint_d,"SPC")
endif
endif

# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


spc:
	@[ $(DESTARCH) != arm64 -o $(SOCFAMILY) != LS -o \
	   $(DISTROVARIANT) = tiny -o $(DISTROVARIANT) = base ] && exit || \
	 $(call repo-mngr,fetch,spc,apps/networking) && \
	 if [ $(DISTROTYPE) = ubuntu -o $(DISTROTYPE) = poky -o $(DISTROTYPE) = debian ]; then \
	     xmlhdr=$(RFSDIR)/usr/include/libxml2; \
	 elif [ $(DISTROTYPE) = buildroot ]; then \
	     xmlhdr=$(RFSDIR)/../host/include/libxml2; \
	 fi && \
	 if [ ! -f $$xmlhdr/libxml/parser.h ]; then \
	     bld rfs -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 export CFLAGS="-I$(RFSDIR)/usr/include/aarch64-linux-gnu" && \
	 export LDFLAGS="-L$(RFSDIR)/usr/lib -Wl,-rpath=$(RFSDIR)/usr/lib:$(RFSDIR)/usr/lib/aarch64-linux-gnu" && \
	 \
	 $(MAKE) -C $(NETDIR)/spc/source \
		 LIBXML2_HEADER_PATH=$$xmlhdr \
		 TCLAP_HEADER_PATH=$(RFSDIR)/usr/include \
		 NET_USPACE_HEADER_PATH=$(NETDIR)/spc/source/include/net \
		 CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)" \
		 CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 cp -rf $(NETDIR)/spc/source/spc $(DESTDIR)/usr/local/bin && \
	 cp -rf $(NETDIR)/spc/etc $(DESTDIR) && \
	 $(call fbprint_d,"SPC")

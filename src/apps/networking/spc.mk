# Copyright 2017-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


spc:
	@[ $(SOCFAMILY) != LS -o $(DISTROVARIANT) != server ] && exit || \
	 $(call download_repo,spc,apps/networking) && \
	 $(call patch_apply,spc,apps/networking) && \
	 if [ $(DISTROTYPE) = ubuntu -o $(DISTROTYPE) = poky -o $(DISTROTYPE) = debian ]; then \
	     xmlhdr=$(RFSDIR)/usr/include/libxml2; \
	 elif [ $(DISTROTYPE) = buildroot ]; then \
	     xmlhdr=$(RFSDIR)/../host/include/libxml2; \
	 fi && \
	 if [ ! -f $$xmlhdr/libxml/parser.h ]; then \
	     bld rfs -m $(MACHINE); \
	 fi && \
	 $(call fbprint_b,"spc") && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)" && \
	 export CFLAGS="-fpermissive -I$(RFSDIR)/usr/include/aarch64-linux-gnu" && \
	 export LDFLAGS="-L$(RFSDIR)/usr/lib -L$(RFSDIR)/usr/lib/aarch64-linux-gnu" && \
	 \
	 $(MAKE) -C $(NETDIR)/spc/source \
		 LIBXML2_HEADER_PATH=$$xmlhdr \
		 TCLAP_HEADER_PATH=$(RFSDIR)/usr/include \
		 NET_USPACE_HEADER_PATH=$(NETDIR)/spc/source/include/net $(LOG_MUTE) && \
	 cp -rf $(NETDIR)/spc/source/spc $(DESTDIR)/usr/local/bin && \
	 cp -rf $(NETDIR)/spc/etc $(DESTDIR) && \
	 $(call fbprint_d,"spc")

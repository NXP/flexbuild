# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



tsntool:
ifeq ($(CONFIG_TSNTOOL), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(SOCFAMILY) != LS -a $(DISTROTYPE) != ubuntu -a $(DISTROTYPE) != yocto -o \
	   $(DISTROTYPE) = buildroot -o $(DISTROSCALE) = tiny -o $(DISTROSCALE) = desktop ] && exit || \
	 $(call fbprint_b,"tsntool") && \
	 $(call repo-mngr,fetch,tsntool,apps/networking) && \
	 $(call repo-mngr,fetch,linux,linux) && \
	 if [ $(DISTROTYPE) = ubuntu -a ! -f $(RFSDIR)/lib/aarch64-linux-gnu/libnl-genl-3.so ] || \
	    [ $(DISTROTYPE) = yocto -a ! -f $(RFSDIR)/usr/lib/libnl-genl-3.so ]; then \
	     bld -i mkrfs -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/include/cjson/cJSON.h ]; then \
	     bld -c cjson -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 export CFLAGS="-I$(DESTDIR)/usr/include -I$(RFSDIR)/usr/include/libnl3" && \
	 export LDFLAGS="-lcjson -lnl-3 -lnl-genl-3 -L$(DESTDIR)/usr/lib/aarch64-linux-gnu \
	                 -L$(RFSDIR)/usr/lib -L$(RFSDIR)/usr/lib/aarch64-linux-gnu" && \
	 cd $(NETDIR)/tsntool && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export PKG_CONFIG_SYSROOT_DIR=$(RFSDIR) && \
	 export PKG_CONFIG_LIBDIR=$(RFSDIR)/usr/local/lib/pkgconfig:$(RFSDIR)/lib/pkgconfig:$(RFSDIR)/lib/aarch64-linux-gnu/pkgconfig && \
	 mkdir -p include/linux && \
	 cp -f $(KERNEL_PATH)/include/uapi/linux/tsn.h include/linux && \
	 $(MAKE) clean && $(MAKE) && \
	 install -d $(DESTDIR)/usr/local/bin && install -d $(DESTDIR)/usr/lib && \
	 install -m 755 tsntool $(DESTDIR)/usr/local/bin/tsntool && \
	 install -m 755 libtsn.so $(DESTDIR)/usr/lib/libtsn.so && \
	 $(call fbprint_d,"tsntool")
endif
endif

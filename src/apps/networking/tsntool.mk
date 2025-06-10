# Copyright 2017-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# depends on libnl-3-dev

tsntool:
	@[ $(DISTROVARIANT) = tiny -o $(DISTROVARIANT) = base ] && exit || \
	 $(call fbprint_b,"tsntool") && \
	 $(call repo-mngr,fetch,tsntool,apps/networking) && \
	 $(call repo-mngr,fetch,linux,linux) && \
	 if [ ! -f $(RFSDIR)/lib/aarch64-linux-gnu/libnl-genl-3.so -a ! -f $(RFSDIR)/usr/lib/libnl-genl-3.so ]; then \
	     echo missing libnl-genl-3.so in $(RFSDIR) && exit 1; \
	 fi && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export CFLAGS="-I$(DESTDIR)/usr/include -I$(RFSDIR)/usr/include/libnl3 -I$(RFSDIR)/usr/include/aarch64-linux-gnu" && \
	 export LDFLAGS="-lcjson -lnl-3 -lnl-genl-3 -L$(DESTDIR)/usr/lib/aarch64-linux-gnu \
	                 -L$(RFSDIR)/usr/lib -L$(RFSDIR)/usr/lib/aarch64-linux-gnu" && \
	 \
	 cd $(NETDIR)/tsntool && \
	 mkdir -p include/linux && \
	 cp -f $(KERNEL_PATH)/include/uapi/linux/tsn.h include/linux && \
	 $(MAKE) clean && \
	 $(MAKE) -j$(JOBS) $(LOG_MUTE) && \
	 install -d $(DESTDIR)/usr/local/bin && install -d $(DESTDIR)/usr/lib && \
	 install -m 755 tsntool $(DESTDIR)/usr/local/bin/tsntool && \
	 install -m 755 libtsn.so $(DESTDIR)/usr/lib/libtsn.so && \
	 $(call fbprint_d,"tsntool")

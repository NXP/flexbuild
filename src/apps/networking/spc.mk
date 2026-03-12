# Copyright 2017-2024,2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


spc:
	@$(call download_repo,spc,apps/networking)
	 $(call patch_apply,spc,apps/networking)
	 xmlhdr=$(RFSDIR)/usr/include/libxml2
	 $(call fbprint_b,"spc")
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)"
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)"
	 export CFLAGS="-fpermissive -I$(RFSDIR)/usr/include/aarch64-linux-gnu"
	 export LDFLAGS="-L$(RFSDIR)/usr/lib -L$(RFSDIR)/usr/lib/aarch64-linux-gnu"
	 $(MAKE) -C $(NETDIR)/spc/source \
		 LIBXML2_HEADER_PATH=$$xmlhdr \
		 TCLAP_HEADER_PATH=$(RFSDIR)/usr/include \
		 NET_USPACE_HEADER_PATH=$(NETDIR)/spc/source/include/net $(LOG_MUTE)
	 cp -rf $(NETDIR)/spc/source/spc $(DESTDIR)/usr/local/bin
	 cp -rf $(NETDIR)/spc/etc $(DESTDIR)
	 $(call fbprint_d,"spc")

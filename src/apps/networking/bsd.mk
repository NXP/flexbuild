# Copyright 2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


bsd:
	 $(call download_repo,bsd,apps/networking) && \
	 $(call patch_apply,bsd,apps/networking) && \
	 $(call fbprint_b,"bsd") && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export CFLAGS="-I$(DESTDIR)/usr/include -I$(RFSDIR)/usr/include/aarch64-linux-gnu" && \
	 export LDFLAGS="-L$(DESTDIR)/usr/lib/aarch64-linux-gnu \
			-L$(RFSDIR)/usr/lib -L$(RFSDIR)/usr/lib/aarch64-linux-gnu" && \
	 cd $(NETDIR)/bsd && \
	 sed -i 's/m4_esyscmd(\[.\/get-version\])/\[0.12.0\]/' configure.ac && \
	 chmod +x autogen get-version && \
	 ./autogen --prefix=/usr --host=aarch64-linux-gnu --with-sysroot=$(RFSDIR) $(LOG_MUTE) && \
	echo "/* empty */" > src/md5.c && \
	echo "/* empty */" > src/md5hl.c && \
	./configure \
	  --host=aarch64-linux-gnu \
	  --prefix=/usr \
	  --enable-static \
	  --enable-shared \
	  --enable-overlay \
	  ac_cv_func_MD5Init=yes \
	  ac_cv_func_MD5Update=yes \
	  ac_cv_git_version=0.12.0 \
	  ac_cv_func_MD5Final=yes \
	  ac_cv_search_MD5Update="none required" && \
	$(MAKE) -j$(nproc) $(LOG_MUTE) && \
	$(MAKE) install DESTDIR=$(RFSDIR) $(LOG_MUTE) && \
	$(MAKE) install DESTDIR=$(DESTDIR) $(LOG_MUTE) && \
	sudo rm -f $(RFSDIR)/usr/lib/libbsd.so $(DESTDIR)/usr/lib/libbsd.so && \
	sudo ln -sf $(RFSDIR)/usr/lib/libbsd.so.0.12.0 $(RFSDIR)/usr/lib/libbsd.so && \
	sudo ln -sf $(DESTDIR)/usr/lib/libbsd.so.0.12.0 $(DESTDIR)/usr/lib/libbsd.so && \
	$(call fbprint_d,"bsd")

# Copyright 2025 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



mbedtls:
	$(call download_repo,mbedtls,apps/security,submod) && \
	$(call patch_apply,mbedtls,apps/security) && \
	\
	$(call fbprint_b,"mbedtls") && \
	cd $(SECDIR)/mbedtls && \
	export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)" && \
	export AR="$(CROSS_COMPILE)ar" && \
	export CFLAGS="-O2 -I$(DESTDIR)/usr/include -I$(RFSDIR)/usr/include $(EXTRA_CFLAGS)" && \
	export LDFLAGS="-L$(DESTDIR)/usr/lib -L$(RFSDIR)/usr/lib $(EXTRA_LDFLAGS)" && \
	rm -rf build && mkdir -p build && cd build && \
	cmake .. -Wno-dev \
		-DCMAKE_INSTALL_PREFIX=/usr \
		-DCMAKE_INSTALL_LIBDIR:PATH=lib \
		-DCMAKE_INSTALL_INCLUDEDIR:PATH=include \
		-DCMAKE_INSTALL_DATAROOTDIR:PATH=share \
		-DCMAKE_INSTALL_BINDIR:PATH=bin \
		-DCMAKE_INSTALL_SBINDIR:PATH=sbin \
		-DCMAKE_INSTALL_LIBEXECDIR:PATH=libexec \
		-DCMAKE_INSTALL_SYSCONFDIR:PATH=/etc \
		-DUSE_SHARED_MBEDTLS_LIBRARY=ON \
		-DMBEDTLS_FATAL_WARNINGS=OFF \
		-DENABLE_PROGRAMS=ON \
		-DENABLE_TESTING=ON $(LOG_MUTE) && \
	$(MAKE) -j$(JOBS) $(LOG_MUTE) && \
	$(MAKE) install DESTDIR=$(DESTDIR) $(LOG_MUTE) && \
	cd $(SECDIR)/mbedtls && \
	sed -i 's+$(SECDIR)/mbedtls/++g' build/tests/*.c 2>/dev/null || : && \
	sed -i 's+build/++g' build/tests/*.c 2>/dev/null || : && \
	install -d $(DESTDIR)/usr/lib/mbedtls/ptest/tests && \
	install -d $(DESTDIR)/usr/lib/mbedtls/ptest/framework && \
	cp -f build/tests/test_suite_* $(DESTDIR)/usr/lib/mbedtls/ptest/tests/ && \
	find $(DESTDIR)/usr/lib/mbedtls/ptest/tests/ -type f -name "*.c" -delete && \
	cp -fR framework/data_files $(DESTDIR)/usr/lib/mbedtls/ptest/framework/ && \
	$(call fbprint_d,"mbedtls")

# Copyright 2023-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
arm_ral:
	@$(call download_repo,arm_ral,apps/networking,git) && \
	$(call fbprint_b,"arm_ral") && \
	if [ ! -d $(RFSDIR)/usr/lib ]; then \
	     bld rfs -m $(MACHINE); \
	fi && \
	cd $(NETDIR)/arm_ral && \
	rm -rf build && mkdir -p build && cd build && \
	export CXX=$(CROSS_COMPILE)g++ && \
	export CC=$(CROSS_COMPILE)gcc && \
        cmake -DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_INSTALL_PREFIX=/usr \
		-DCMAKE_INSTALL_LIBDIR=lib \
		-DBUILD_TESTING=On \
		-DBUILD_EXAMPLES=On \
		../ && \
        make -j$(JOBS) && \
        DESTDIR=$(RFSDIR) make install && \
        $(call fbprint_d,"arm_ral")

# Copyright 2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# Plug & Trust ECC example for NXP EdgeLock SE050 secure element product family

# This example demonstrates Elliptic Curve Cryptography (ECC) sign and verify operation
# using NXP Plug & Trust middleware for EdgeLock SE050 secure element family.


ecc_example:
	@[ $(SOCFAMILY) != IMX  ] && exit || \
	 $(call download_repo,ecc_example,apps/security) && \
	 $(call patch_apply,ecc_example,apps/security) && \
	 $(call fbprint_b,"ecc_example") && \
	 cd $(SECDIR)/ecc_example && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 mkdir -p build_$(DISTROTYPE)_$(ARCH) $(DESTDIR)/usr/bin && \
	 cmake  -S $(SECDIR)/ecc_example/ecc_example \
		-B build_$(DISTROTYPE)_$(ARCH) \
		-DCMAKE_BUILD_TYPE=release $(LOG_MUTE) && \
	 cmake --build build_$(DISTROTYPE)_$(ARCH) --target all $(LOG_MUTE) && \
	 cmake --install build_$(DISTROTYPE)_$(ARCH) --prefix /usr $(LOG_MUTE) && \
	 install -m 0755 build_$(DISTROTYPE)_$(ARCH)/ex_ecc $(DESTDIR)/usr/bin/ && \
	 $(call fbprint_d,"ecc_example")

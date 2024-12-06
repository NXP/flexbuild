# Copyright 2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# Plug & Trust ECC example for NXP EdgeLock SE050 secure element product family

# This example demonstrates Elliptic Curve Cryptography (ECC) sign and verify operation
# using NXP Plug & Trust middleware for EdgeLock SE050 secure element family.


ecc_example:
	@[ $(SOCFAMILY) != IMX -o $(DISTROVARIANT) = base -o $(DISTROVARIANT) = tiny ] && exit || \
	 $(call fbprint_b,"ecc_example") && \
	 $(call repo-mngr,fetch,ecc_example,apps/security) && \
	 cd $(SECDIR)/ecc_example && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 mkdir -p build_$(DISTROTYPE)_$(ARCH) $(DESTDIR)/usr/bin && \
	 cmake  -S $(SECDIR)/ecc_example/ecc_example \
		-B build_$(DISTROTYPE)_$(ARCH) \
		-DCMAKE_BUILD_TYPE=release && \
	 cmake --build build_$(DISTROTYPE)_$(ARCH) --target all && \
	 cmake --install build_$(DISTROTYPE)_$(ARCH) --prefix /usr && \
	 install -m 0755 build_$(DISTROTYPE)_$(ARCH)/ex_ecc $(DESTDIR)/usr/bin/ && \
	 $(call fbprint_d,"ecc_example")

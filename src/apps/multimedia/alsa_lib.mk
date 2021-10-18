# Copyright 2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# alsa-lib is a library to interface with ALSA (Advanced Linux Sound Architecture)
# in the Linux kernel and virtual devices using a plugin system.


alsa_lib:
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) != desktop ] && exit || \
	 $(call fbprint_b,"alsa_lib") && \
	 $(call repo-mngr,fetch,alsa_lib,apps/multimedia) && \
	 cd $(MMDIR)/alsa_lib && \
	 libtoolize --force --copy --automake && aclocal && \
	 autoheader && automake --foreign --copy --add-missing && autoconf && \
	 ./configure --host=aarch64 CC=aarch64-linux-gnu-gcc 1>/dev/null && \
	 $(MAKE) -j$(JOBS) install && \
	 $(call fbprint_d,"alsa_lib")
endif

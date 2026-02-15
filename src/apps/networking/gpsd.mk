# Copyright 2023-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
CONFIG_APP_GPSD ?= n

gpsd:
	@set -e; \
	if [ "$(strip $(CONFIG_APP_GPSD))" != "y" ]; then \
		echo "Skipping gpsd: CONFIG_APP_GPSD!='y' (current='$(strip $(CONFIG_APP_GPSD))')"; \
		exit 0; \
	fi && \
	$(call fbprint_b,"gpsd") && \
	if [ ! -d $(NETDIR)/gpsd-3.27 ]; then \
	cd $(NETDIR) && wget --no-check-certificate $(repo_gpsd_src_url) $(LOG_MUTE) && tar -zxvf gpsd-3.27.tar.gz $(LOG_MUTE); fi && \
	rm -rf gpsd-3.27.tar.gz && cd $(NETDIR)/gpsd-3.27 && \
	export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)" && \
	export CPP="$(CROSS_COMPILE)cpp --sysroot=$(RFSDIR)" && \
	export AS="$(CROSS_COMPILE)as" && export LD="$(CROSS_COMPILE)ld --sysroot=$(RFSDIR)" && \
	export STRIP=$(CROSS_COMPILE)strip && export RANLIB=$(CROSS_COMPILE)ranlib && \
	export LDFLAGS="-L$(RFSDIR)/lib/aarch64-linux-gnu -L$(RFSDIR)/lib -L$(RFSDIR)/usr/lib" && \
	export LINKFLAGS="-L$(RFSDIR)/lib/aarch64-linux-gnu -L$(RFSDIR)/lib -L$(RFSDIR)/usr/lib"  && \
	scons  manbuild=no prefix=/usr sysroot=$(RFSDIR) python_libdir=/usr/local/lib/python3.6/dist-packages/ strip=no qt=no debug=false usb=no $(LOG_MUTE) && \
	scons manbuild=no prefix=/usr sysroot=$(RFSDIR) python_libdir=/usr/local/lib/python3.6/dist-packages/ strip=no qt=no  debug=false  usb=no install $(LOG_MUTE) && \
	$(call fbprint_d,"gpsd")

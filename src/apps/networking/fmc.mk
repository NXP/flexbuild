# Copyright 2017-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# FMC (Frame Manager Configuration) tool is a software package for DPAA on QorIQ/Layerscape platform

# depend on libtclap-dev for tclap/CmdLine.h

fmc: fmlib
	@[ $(SOCFAMILY) != LS -o $(DISTROVARIANT) != server ] && exit || \
	 $(call repo-mngr,fetch,fmc,apps/networking) && \
	 $(call repo-mngr,fetch,eth_config,apps/networking) && \
	 if [ ! -d $(DESTDIR)/etc/fmc/config ]; then \
	     mkdir -p $(DESTDIR)/etc/fmc/config && \
	     cp -rf $(NETDIR)/eth_config/private $(NETDIR)/eth_config/shared_mac $(DESTDIR)/etc/fmc/config; \
	 fi && \
	 if [ $(DISTROTYPE) = debian -o $(DISTROTYPE) = ubuntu -o $(DISTROTYPE) = poky ]; then \
	     xmlhdr=$(RFSDIR)/usr/include/libxml2; \
	 elif [ $(DISTROTYPE) = buildroot ]; then \
	     xmlhdr=$(RFSDIR)/../host/include/libxml2; \
	 fi && \
	 if [ ! -d $(NETDIR)/fmlib/include/fmd/Peripherals -o ! -f $(DESTDIR)/usr/lib/libfm-arm.a ]; then \
	     bld fmlib -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH) -p LS; \
	 fi && \
	 if [ ! -f $$xmlhdr/libxml/parser.h ]; then \
	     bld rfs -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH) -p LS; \
	 fi && \
	 if [ ! -d $(KERNEL_PATH)/include/uapi/linux/fmd ]; then \
	     bld linux -a $(DESTARCH) -p $(SOCFAMILY); \
	 fi && \
	 $(call fbprint_b,"fmc") && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)" && \
	 export LDFLAGS="-L$(RFSDIR)/usr/lib -L$(DESTDIR)/usr/lib -L$(RFSDIR)/usr/lib/aarch64-linux-gnu" && \
	 export CFLAGS="-Wno-write-strings -fpermissive -I$(RFSDIR)/usr/include/aarch64-linux-gnu -I$(NETDIR)/fmlib/include/fmd \
		-I$(NETDIR)/fmlib/include/fmd/Peripherals -I$(NETDIR)/fmlib/include/fmd/integrations" && \
	 \
	 cd $(NETDIR)/fmc && \
	 $(MAKE) -C source \
	 	 FMD_USPACE_HEADER_PATH=$(KERNEL_PATH)/include/uapi/linux/fmd \
		 FMLIB_HEADER_PATH=$(NETDIR)/fmlib/include \
		 LIBXML2_HEADER_PATH=$$xmlhdr \
		 FMD_USPACE_LIB_PATH=$(DESTDIR)/usr/lib \
		 TCLAP_HEADER_PATH=$(RFSDIR)/usr/include \
		 CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)" \
		 CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" $(LOG_MUTE) && \
	 install -d $(DESTDIR)/usr/local/bin && \
	 install -m 755 source/fmc $(DESTDIR)/usr/local/bin/fmc && \
	 install -d $(DESTDIR)/etc/fmc/config && \
	 install -m 644 etc/fmc/config/hxs_pdl_v3.xml $(DESTDIR)/etc/fmc/config && \
	 install -m 644 etc/fmc/config/netpcd.xsd $(DESTDIR)/etc/fmc/config && \
	 install -d $(DESTDIR)/usr/local/include/fmc && \
	 install source/fmc.h $(DESTDIR)/usr/local/include/fmc && \
	 install -d $(DESTDIR)/usr/local/lib/aarch64-linux-gnu && \
	 install source/libfmc.a $(DESTDIR)/usr/local/lib/aarch64-linux-gnu && \
	 install -d $(DESTDIR)/usr/local/fmc/ && \
	 install -m 755 $(FBDIR)/src/system/init-ls104xa $(DESTDIR)/usr/local/fmc && \
	 install -d $(DESTDIR)/usr/lib/systemd/system/ && \
	 install -d $(DESTDIR)/etc/systemd/system/multi-user.target.wants/ && \
	 install -m 644 $(FBDIR)/src/system/fmc.service $(DESTDIR)/usr/lib/systemd/system/ && \
	 $(call fbprint_d,"fmc")

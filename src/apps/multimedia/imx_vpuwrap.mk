# Copyright 2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# iMX multimedia VPU wrapper


imx_vpuwrap:
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) != desktop ] && exit || true && \
	 $(call fbprint_b,"imx_vpuwrap") && \
	 $(call repo-mngr,fetch,imx_vpuwrap,apps/multimedia) && \
	 cd $(MMDIR) && \
	 if [ ! -f $(DESTDIR)/usr/lib/libcodec.so ]; then \
	     bld -c imx_vpu -r $(DISTROTYPE):$(DISTROSCALE) -f $(CFGLISTYML); \
	 fi && \
	 cd imx_vpuwrap && \
	 export CFLAGS="-I$(DESTDIR)/usr/include -I$(DESTDIR)/usr/include/hantro_dec -I$(DESTDIR)/usr/include/hantro_enc" && \
	 export LDFLAGS="-L$(DESTDIR)/usr/lib -Wl,-O2" && \
	 if [ ! -f /usr/bin/libtool ]; then sudo ln -s libtoolize /usr/bin/libtool; fi && \
	 ./autogen.sh --prefix=/usr --host=aarch64-linux-gnu --with-sysroot=$(RFSDIR) 1>/dev/null && \
	 sed -e 's/^am__append_3/#am__append_3/' -e 's/^am__append_5/#am__append_5/' \
	     -e 's/^am__append_8/#am__append_8/' -e 's/^am__objects_3/#am__objects_3/' \
	     -e 's/^am__DEPENDENCIES_2/#am__DEPENDENCIES_2/' -e 's/^am__append_5/#am__append_5/' \
	     -e 's/^include /#include /' -i Makefile && \
	 $(MAKE) DEST_DIR=$(DESTDIR) SDKTARGETSYSROOT=$(DESTDIR) CC=aarch64-linux-gnu-gcc && \
	 $(MAKE) DEST_DIR=$(DESTDIR) SDKTARGETSYSROOT=$(DESTDIR) install && \
	 $(call fbprint_d,"imx_vpuwrap")
endif

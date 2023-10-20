# Copyright 2021-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# iMX multimedia VPU wrapper


imx_vpuwrap:
	@[ $(DISTROVARIANT) != desktop -o $(SOCFAMILY) != IMX ] && exit || \
	 $(call fbprint_b,"imx_vpuwrap") && \
	 $(call repo-mngr,fetch,imx_vpuwrap,apps/multimedia) && \
	 if [ ! -f $(DESTDIR)/usr/lib/libcodec.so ]; then \
	     bld imx_vpu_hantro -r $(DISTROTYPE):$(DISTROVARIANT) -f $(CFGLISTYML); \
	 fi && \
	 cd $(MMDIR)/imx_vpuwrap && \
	 export CFLAGS="-I$(DESTDIR)/usr/include -I$(DESTDIR)/usr/include/hantro_dec -I$(DESTDIR)/usr/include/hantro_enc" && \
	 export LDFLAGS="-L$(DESTDIR)/usr/lib -Wl,-O2" && \
	 if [ ! -f /usr/bin/libtool ]; then sudo ln -s libtoolize /usr/bin/libtool; fi && \
	 ./autogen.sh --prefix=/usr --host=aarch64-linux-gnu --with-sysroot=$(RFSDIR) 1>/dev/null && \
	 sed -e 's/^am__append_3/#am__append_3/' -e 's/^am__append_5/#am__append_5/' \
	     -e 's/^am__append_8/#am__append_8/' -e 's/^am__objects_3/#am__objects_3/' \
	     -e 's/^am__DEPENDENCIES_2/#am__DEPENDENCIES_2/' -e 's/^am__append_5/#am__append_5/' \
	     -e 's/^include /#include /' -i Makefile && \
	 if [ ! -f $(DESTDIR)/usr/include/hantro_VC8000E_enc/hevcencapi.h ]; then \
	     bld imx_vpu_hantro_vc -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 $(MAKE) DEST_DIR=$(DESTDIR) SDKTARGETSYSROOT=$(DESTDIR) CC=aarch64-linux-gnu-gcc && \
	 $(MAKE) DEST_DIR=$(DESTDIR) SDKTARGETSYSROOT=$(DESTDIR) install && \
	 echo installed examples in $(DESTDIR)/usr/share/imx-mm/video-codec/examples && \
	 $(call fbprint_d,"imx_vpuwrap")

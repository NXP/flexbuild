# Copyright 2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# i.MX Verisilicon Software ISP for imx8mp
# DEPENDS: libpython3 bash systemd libdrm virtual/libg2d



imx_isp:
ifeq ($(CONFIG_IMX_ISP), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) != desktop ] && exit || \
	 $(call fbprint_b,"imx_isp") && \
	 cd $(MMDIR) && \
	 if [ ! -d $(MMDIR)/imx_isp ]; then \
	     wget -q $(repo_imx_isp_bin_url) -O imxisp.bin && \
	     chmod +x imxisp.bin && ./imxisp.bin --auto-accept && \
	     mv isp-imx-* imx_isp && rm -f imxisp.bin; \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/libg2d.so ]; then \
	     bld -c imx_g2d -r $(DISTROTYPE):$(DISTROSCALE) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/libOpenCL.so ]; then \
	     bld -c gpulib -r $(DISTROTYPE):$(DISTROSCALE) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/include/xf86drm.h ]; then \
	     bld -c libdrm -r $(DISTROTYPE):$(DISTROSCALE) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/include/imx/linux/dma-buf.h ]; then \
	     bld -c imx_vpu -r $(DISTROTYPE):$(DISTROSCALE) -f $(CFGLISTYML); \
	 fi && \
	 cd imx_isp/appshell && \
	 rm -rf build && \
	 mkdir -p build && cd build && \
	 export CC=$(CROSS_COMPILE)gcc && \
	 export CXX=$(CROSS_COMPILE)g++ && \
	 export LDFLAGS="-L$(DESTDIR)/usr/lib -Wl,-rpath=$(DESTDIR)/usr/lib:$(RFSDIR)/usr/lib/aarch64-linux-gnu" && \
	 cmake .. -G "Unix Makefiles" \
		-DSDKTARGETSYSROOT=$(DESTDIR) \
		-DCMAKE_BUILD_TYPE=release \
		-DISP_VERSION=ISP8000NANO_V1802 \
		-DPLATFORM=ARM64 \
		-DAPPMODE=V4L2 \
		-DQTLESS=1 \
		-DFULL_SRC_COMPILE=1 \
		-DWITH_DRM=1 \
		-DWITH_DWE=1 \
		-DSERVER_LESS=1 \
		-DSUBDEV_V4L2=1 \
		-DENABLE_IRQ=1 \
		-DPARTITION_BUILD=0 \
		-D3A_SRC_BUILD=0 \
		-DIMX_G2D=ON \
		-Wno-dev \
		-DCMAKE_CXX_FLAGS="-I$(DESTDIR)/usr/include -I$(DESTDIR)/usr/include/libdrm" && \
	 $(MAKE) -j$(JOBS) && \
	 install -d $(DESTDIR)/opt/imx8-isp/bin && \
	 install -d $(DESTDIR)/usr/lib/systemd/system && \
	 install -d $(DESTDIR)/etc/systemd/system/multi-user.target.wants && \
	 cp -r generated/release/bin/*_test $(DESTDIR)/opt/imx8-isp/bin && \
	 cp -r generated/release/bin/*2775* $(DESTDIR)/opt/imx8-isp/bin && \
	 cp -r generated/release/bin/isp_media_server $(DESTDIR)/opt/imx8-isp/bin && \
	 cp -r generated/release/bin/vvext $(DESTDIR)/opt/imx8-isp/bin && \
	 cp -r generated/release/lib/*.so* $(DESTDIR)/usr/lib && \
	 cp -r generated/release/include/* $(DESTDIR)/usr/include && \
	 cp -r $(MMDIR)/imx_isp/dewarp/dewarp_config $(DESTDIR)/opt/imx8-isp/bin && \
	 cp $(MMDIR)/imx_isp/imx/run.sh $(DESTDIR)/opt/imx8-isp/bin && \
	 cp $(MMDIR)/imx_isp/imx/start_isp.sh $(DESTDIR)/opt/imx8-isp/bin && \
	 chmod +x $(DESTDIR)/opt/imx8-isp/bin/run.sh && \
	 chmod +x $(DESTDIR)/opt/imx8-isp/bin/start_isp.sh && \
	 install -m 0644 $(MMDIR)/imx_isp/imx/imx8-isp.service $(DESTDIR)/usr/lib/systemd/system/ && \
	 ln -sf /usr/lib/systemd/system/imx8-isp.service $(DESTDIR)/etc/systemd/system/multi-user.target.wants/imx8-isp.service && \
	 $(call fbprint_d,"imx_isp")
endif
endif

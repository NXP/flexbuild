# Copyright 2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# Basler camera binary drivers for iMX8


basler_camera:
ifeq ($(CONFIG_BASLER_CAMERA), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) != desktop ] && exit || true && \
	 $(call fbprint_b,"basler_camera") && \
	 cd $(MMDIR) && \
	 if [ ! -d $(MMDIR)/basler_camera ]; then \
	     wget -q $(repo_basler_camera_bin_url) -O basler_camera.bin && \
	     chmod +x basler_camera.bin && ./basler_camera.bin --auto-accept && \
	     mv basler-camera-* basler_camera && rm -f basler_camera.bin; \
	 fi && \
	 cd basler_camera && \
	 install -d $(DESTDIR)/opt/imx8-isp/bin && \
	 cp -rfv ./opt/imx8-isp/bin/* $(DESTDIR)/opt/imx8-isp/bin && \
	 cp -rfv ./usr/lib/* $(DESTDIR)/usr/lib/ && \
	 $(call fbprint_d,"basler_camera")
endif
endif

# Copyright 2021-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# Basler camera binary drivers for iMX8MP


basler_camera:
ifeq ($(CONFIG_BASLER_CAMERA),y)
	@[ $(DISTROVARIANT) != desktop -o $(SOCFAMILY) != IMX ] && exit || \
	 $(call fbprint_b,"basler_camera") && \
	 cd $(MMDIR) && \
	 if [ ! -d $(MMDIR)/basler_camera ]; then \
		 rm -rf basler_camera*; \
	     $(WGET) $(repo_basler_camera_bin_url) -O basler_camera.bin $(LOG_MUTE); \
		 [ $$? -ne 0 ] && { echo "Downloading $(repo_basler_camera_bin_url) failed."; exit 1; } || \
	     chmod +x basler_camera.bin && ./basler_camera.bin --auto-accept --force $(LOG_MUTE); \
	     mv basler-camera-* basler_camera && rm -f basler_camera.bin; \
	 fi && \
	 cd basler_camera && \
	 install -d $(DESTDIR)/opt/imx8-isp/bin && \
	 cp -rfv ./opt/imx8-isp/bin/* $(DESTDIR)/opt/imx8-isp/bin && \
	 cp -rfv ./usr/lib/* $(DESTDIR)/usr/lib/ && \
	 $(call fbprint_d,"basler_camera")
endif

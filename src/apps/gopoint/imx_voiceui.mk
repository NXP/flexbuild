# Copyright 2025 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# section: iMX multimedia
# description: NXP RetuneDSP Voice Seeker Libraries
# 
# depends on: alsa-lib nxp-afe
#

GPNT_APPS_FOLDER = /opt/gopoint-apps
IMX_VOICE_PLAYER_DIR = $(GPNT_APPS_FOLDER)/scripts/multimedia/imx-voiceplayer

BARCH := $(shell \
	if echo $(MACHINE) | grep -q '^imx9'; then echo CortexA55; \
	elif echo $(MACHINE) | grep -q '^imx8'; then echo CortexA53; \
	else echo ERROR; fi)

imx_voiceui:
ifeq ($(CONFIG_IMX_VOICEUI),y)
#imx_voiceui: nxp_afe nxp_demo_experience_assets
	@[ $(SOCFAMILY) != IMX ] && exit || \
	 $(call download_repo,imx_voiceui,apps/gopoint) && \
	 $(call patch_apply,imx_voiceui,apps/gopoint) && \
	 \
	 $(call fbprint_b,"imx_voiceui") && \
	 cd $(GPDIR)/imx_voiceui && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)" && \
	 \
	 install -d $(DESTDIR)/usr/lib/nxp-afe && \
	 install -d $(DESTDIR)/unit_tests/nxp-afe && \
	 $(MAKE) clean && \
	 exit 1 && \
	 $(MAKE) -j$(JOBS) all enable-armv8=1 bindir=$(DESTDIR)/unit_tests/ libdir=$(DESTDIR)/usr/lib \
		BUILD_ARCH=$(BARCH) $(LOG_MUTE) && \
	 install -m 0644 release/libvoiceseekerlight.so.2.0 $(DESTDIR)/usr/lib/nxp-afe/ && \
	 install -m 0755 release/voice_ui_app    $(DESTDIR)/unit_tests/nxp-afe/ && \
	 install -m 0644 release/Config.ini    $(DESTDIR)/unit_tests/nxp-afe && \
	 \
# The following is for imx-voice-example && \
	 if [ "$(BARCH)" = "CortexA53" ]; then \
	 	cp -f $(GPDIR)/nxp_demo_experience_assets/build/demo-experience-voice-demo/VIT_Model_en.h \
			vit/platforms/iMX8M_CortexA53/lib/VIT_Model_en.h; \
	 else \
	 	cp -f $(GPDIR)/nxp_demo_experience_assets/build/demo-experience-voice-demo/VIT_Model_en.h \
			vit/platforms/iMX9_CortexA55/lib/VIT_Model_en.h; \
	 fi && \
	 $(MAKE) clean && \
	 $(MAKE) VOICE_UI_APP enable-armv8=1 bindir=$(DESTDIR)/unit_tests/ libdir=$(DESTDIR)/usr/lib \
	 	BUILD_ARCH=$(BARCH) $(LOG_MUTE) && \
	 install -d $(DESTDIR)/$(GPNT_APPS_FOLDER)/bin && \
	 install -m 0755 release/voice_ui_app $(DESTDIR)/$(GPNT_APPS_FOLDER)/bin/ && \
	 \
	 exit 1 && \
# The following is for smart-kitchen &&\
	 cp -f $(GPDIR)/nxp_demo_experience_assets/build/demo-experience-smart-kitchen/VIT_Model_en.h \
		vit/platforms/iMX8M_CortexA53/lib/VIT_Model_en.h && \
	 cp -f $(GPDIR)/nxp_demo_experience_assets/build/demo-experience-smart-kitchen/VIT_Model_en.h \
		vit/platforms/iMX9_CortexA55/lib/VIT_Model_en.h && \
	 $(MAKE) clean && \
	 $(MAKE) VOICE_UI_APP enable-armv8=1 bindir=$(DESTDIR)/unit_tests/ libdir=$(DESTDIR)/usr/lib \
	 	BUILD_ARCH=CortexA53 $(LOG_MUTE) && \
	 install -d $(DESTDIR)/$(GPNT_APPS_FOLDER)/scripts/multimedia/smart-kitchen && \
	 install -m 0755 release/voice_ui_app $(DESTDIR)/$(GPNT_APPS_FOLDER)/scripts/multimedia/smart-kitchen/voice_ui_app.a53 && \
	 $(MAKE) clean && \
	 $(MAKE) VOICE_UI_APP enable-armv8=1 bindir=$(DESTDIR)/unit_tests/ libdir=$(DESTDIR)/usr/lib \
	 	BUILD_ARCH=CortexA55 $(LOG_MUTE) && \
	 install -m 0755 release/voice_ui_app $(DESTDIR)/$(GPNT_APPS_FOLDER)/scripts/multimedia/smart-kitchen/voice_ui_app.a55 && \
	 \
# The following is for demo-experience-ebike-vit &&\
	 cp -f $(GPDIR)/nxp_demo_experience_assets/build/demo-experience-ebike-vit/VIT_Model_en.h \
		vit/platforms/iMX8M_CortexA53/lib/VIT_Model_en.h && \
	 cp -f $(GPDIR)/nxp_demo_experience_assets/build/demo-experience-ebike-vit/VIT_Model_en.h \
		vit/platforms/iMX9_CortexA55/lib/VIT_Model_en.h && \
	 $(MAKE) clean && \
	 $(MAKE) VOICE_UI_APP enable-armv8=1 bindir=$(DESTDIR)/unit_tests/ libdir=$(DESTDIR)/usr/lib \
	 	BUILD_ARCH=CortexA53 $(LOG_MUTE) && \
	 install -d $(DESTDIR)/$(GPNT_APPS_FOLDER)/scripts/multimedia/ebike-vit && \
	 install -m 0755 release/voice_ui_app $(DESTDIR)/$(GPNT_APPS_FOLDER)/scripts/multimedia/ebike-vit/voice_ui_app.a53 && \
	 $(MAKE) clean && \
	 $(MAKE) VOICE_UI_APP enable-armv8=1 bindir=$(DESTDIR)/unit_tests/ libdir=$(DESTDIR)/usr/lib \
	 	BUILD_ARCH=CortexA55 $(LOG_MUTE) && \
	 install -m 0755 release/voice_ui_app $(DESTDIR)/$(GPNT_APPS_FOLDER)/scripts/multimedia/ebike-vit/voice_ui_app.a55 && \
	 \
# The following is for demo-experience-voice-player &&\
	 cp -f $(GPDIR)/nxp_demo_experience_assets/build/demo-experience-voice-player/VIT_Model_en.h \
		vit/platforms/iMX8M_CortexA53/lib/VIT_Model_en.h && \
	 cp -f $(GPDIR)/nxp_demo_experience_assets/build/demo-experience-voice-player/VIT_Model_en.h \
		vit/platforms/iMX9_CortexA55/lib/VIT_Model_en.h && \
	 $(MAKE) clean && \
	 $(MAKE) all enable-armv8=1 bindir=$(DESTDIR)/unit_tests/ libdir=$(DESTDIR)/usr/lib \
	 	BUILD_ARCH=CortexA53 $(LOG_MUTE) && \
	 install -d $(DESTDIR)/$(IMX_VOICE_PLAYER_DIR) && \
	 install -d $(DESTDIR)/$(IMX_VOICE_PLAYER_DIR)/i.MX8M_A53 && \
	 install -d $(DESTDIR)/$(IMX_VOICE_PLAYER_DIR)/i.MX9X_A55 && \
	 install -m 0755 release/voice_ui_app $(DESTDIR)/$(IMX_VOICE_PLAYER_DIR)/i.MX8M_A53 && \
	 install -m 0755 release/libvoiceseekerlight.so.2.0 $(DESTDIR)/$(IMX_VOICE_PLAYER_DIR)/i.MX8M_A53 && \
	 $(MAKE) clean && \
	 $(MAKE) all enable-armv8=1 bindir=$(DESTDIR)/unit_tests/ libdir=$(DESTDIR)/usr/lib \
	 	BUILD_ARCH=CortexA55 $(LOG_MUTE) && \
	 install -m 0755 release/voice_ui_app $(DESTDIR)/$(IMX_VOICE_PLAYER_DIR)/i.MX9X_A55 && \
	 install -m 0755 release/libvoiceseekerlight.so.2.0 $(DESTDIR)/$(IMX_VOICE_PLAYER_DIR)/i.MX9X_A55 && \
	 \
	 $(call fbprint_d,"imx_voiceui")
endif

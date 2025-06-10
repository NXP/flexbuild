# Copyright 2025 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
# Description: i.MX Video to Texture application
# 
# depends on: glib-2.0 gstreamer1.0 gstreamer1.0-plugins-good packagegroup-qt6-imx qtbase qtdeclarative qtdeclarative-native
#
GPNT_APPS_FOLDER = /opt/gopoint-apps
IMX_VOICE_PLAYER_DIR = $(GPNT_APPS_FOLDER)/scripts/multimedia/imx-voiceplayer

imx_voiceplayer:
ifeq ($(CONFIG_IMX_VOICEPLAYER),y)
	 [ $(SOCFAMILY) != IMX -o $(DISTROVARIANT) != desktop ] && exit || \
	 $(call repo-mngr,fetch,imx_voiceplayer,apps/gopoint) && \
	 if [[ ! -f $(DESTDIR)/usr/lib/nxp-afe/libvoiceseekerlight.so.2.0 ]]; then \
	     bld imx_voiceui -r $(DISTROTYPE):$(DISTROVARIANT); \
	 fi && \
	 \
	 $(call fbprint_b,"imx_voiceplayer") && \
	 cd $(GPDIR)/imx_voiceplayer && \
	 if [ ! -f .patchdone ]; then \
	     git am $(FBDIR)/patch/imx_voiceplayer/* $(LOG_MUTE) && touch .patchdone; \
	 fi && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)" && \
	 export CFLAGS="-O2 -pipe -g -fPIC -feliminate-unused-debug-types -I$(RFSDIR)/usr/lib/aarch64-linux-gnu/glib-2.0/include" && \
	 export CXXFLAGS="-O2 -pipe -g -fPIC -feliminate-unused-debug-types -I$(RFSDIR)/usr/lib/aarch64-linux-gnu/glib-2.0/include" && \
	 \
	 #### BUILD APP GUI #### && \
	 rm -rf app/build && mkdir -p app/build && cd app/build && \
	 qmake6 ../VoicePlayer.pro && \
	 make -j$(JOBS) $(LOG_MUTE) && \
	 install -d -m 755 $(DESTDIR)/$(IMX_VOICE_PLAYER_DIR) && \
	 install $(GPDIR)/imx_voiceplayer/app/build/VoicePlayer $(DESTDIR)/$(IMX_VOICE_PLAYER_DIR)/ && \
	 cp -fp $(GPDIR)/imx_voiceplayer/scripts/* $(DESTDIR)/${IMX_VOICE_PLAYER_DIR}/ && \
	 \
	 ####  BUILD APP COMPONENTS#### && \
	 cd $(GPDIR)/imx_voiceplayer && \
	 rm -rf msgq/build && mkdir -p msgq/build && cd msgq/build && \
	 cmake .. && make -j$(JOBS) $(LOG_MUTE) && \
	 install MsgQ $(DESTDIR)/$(IMX_VOICE_PLAYER_DIR) && \
	 \
	 #### VOICE_UI was built in imx_voiceui #### && \
	 #### BUILD VOICE ACTION COMPONENTS #### && \
	 \
	 cd $(GPDIR)/imx_voiceplayer/voiceAction && \
	 rm -rf build && make -j$(JOBS) $(LOG_MUTE) && \
	 install -m 0755 build/btp $(DESTDIR)/${IMX_VOICE_PLAYER_DIR} && \
	 cp -rf bridgeVoiceUI/* $(DESTDIR)/${IMX_VOICE_PLAYER_DIR} && \
	 \
	 $(call fbprint_d,"imx_voiceplayer")
endif

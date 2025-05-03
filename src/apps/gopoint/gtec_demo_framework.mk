# Copyright 2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
# Description: i.MX Video to Texture application
# 
# depends on: glib-2.0 gstreamer1.0 gstreamer1.0-plugins-good packagegroup-qt6-imx qtbase qtdeclarative qtdeclarative-native
#
GPNT_GPU_DESTDIR = /opt/imx-gpu-sdk/GLES2/
GPNT_GPU_SOURDIR = $(GPDIR)/gtec_demo_framework/build/Yocto/Ninja/release/DemoApps/GLES2

gtec_demo_framework:
	@[ $(SOCFAMILY) != IMX -o $(DISTROVARIANT) != desktop ] && exit || \
	 $(call fbprint_b,"gtec_demo_framework") && \
	 $(call repo-mngr,fetch,gtec_demo_framework,apps/gopoint) && \
	 \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)" && \
	 export EXTENSIONS="OpenGLES:GL_VIV_direct_texture,OpenGLES3:GL_EXT_color_buffer_float" && \
	 export FEATURES="ConsoleHost,EarlyAccess,EGL,GoogleUnitTest,Lib_NlohmannJson,Lib_pugixml,Test_RequireUserInputToExit,WindowHost,G2D,OpenGLES2,OpenCV4,Vulkan1.2,OpenGLES3.2,OpenCL1.2,OpenVX1.2" && \
	 \
	 ln -sf $(RFSDIR)/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1 /lib/ld-linux-aarch64.so.1 && \
	 cd $(GPDIR)/gtec_demo_framework && \
	 if [ ! -f .patchdone ]; then \
	     git am $(FBDIR)/patch/gtec_demo_framework/*.patch $(LOG_MUTE) && touch .patchdone; \
	 fi && \
	 source ./prepare.sh && export DESTDIR='' && \
	 # *DESTDIR* is for compiling, it is not the *DESTDIR* of flexbuild && \
	 # FslBuild.py -vvvvv -c install --BuildThreads $(JOBS) --CMakeInstallPrefix . && \
	 # --UseFeatures [$${FEATURES}] --UseExtensions [$${EXTENSIONS}] --Variants [WindowSystem=$${WINDOW_SYSTEM}] && \
	 \
	 # Compiling GLES2 DemoApp && \
	 for demoapp in Bloom Blur EightLayerBlend FractalShader LineBuilder101 ModelLoaderBasics S03_Transform S04_Projection S06_Texturing S07_EnvMapping S08_EnvMappingRefraction ; do \
		cd $(GPDIR)/gtec_demo_framework/DemoApps/GLES2/$${demoapp}; \
		FslBuild.py --BuildThreads $(JOBS) --platform yocto --Variants [config=Release,FSL_GLES_NAME=vivante,WindowSystem=Wayland] --UseExtensions [$${EXTENSIONS}] --UseFeatures [$${FEATURES}] $(LOG_MUTE) ; \
		mkdir -p $(DESTDIR)/opt/imx-gpu-sdk/GLES2/$${demoapp}___Wayland/Content; \
		cp -arf $(GPNT_GPU_SOURDIR)/$${demoapp}___Wayland/Content/* $(DESTDIR)/$(GPNT_GPU_DESTDIR)/$${demoapp}___Wayland/Content/; \
		cp -arf $(GPNT_GPU_SOURDIR)/$${demoapp}___Wayland/GLES2.$${demoapp}___Wayland $(DESTDIR)/$(GPNT_GPU_DESTDIR)/$${demoapp}___Wayland/; \
	 done && \
	 \
	 rm -rf /lib/ld-linux-aarch64.so.1 && \
	 $(call fbprint_d,"gtec_demo_framework")

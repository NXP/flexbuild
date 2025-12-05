# Copyright 2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
# Description: i.MX Video to Texture application
# 
# depends on: glib-2.0 gstreamer1.0 gstreamer1.0-plugins-good packagegroup-qt6-imx qtbase qtdeclarative qtdeclarative-native
#

ifeq ($(filter imx95%,$(MACHINE)),$(MACHINE))
  EXT_GTEC = "OpenGLES3:GL_EXT_color_buffer_float,OpenGLES3:GL_EXT_geometry_shader,OpenGLES3:GL_EXT_tessellation_shader"
  DEP_GTEC = mali_imx
else ifeq ($(filter imx8%,$(MACHINE)),$(MACHINE))
  EXT_GTEC = "OpenGLES:GL_VIV_direct_texture,OpenGLES3:GL_EXT_color_buffer_float"
  DEP_GTEC = gpu_viv
endif


GPNT_GPU_DESTDIR = /opt/imx-gpu-sdk/GLES2/
GPNT_GPU_SOURDIR = $(GPDIR)/gtec_demo_framework/build/Yocto/Ninja/release/DemoApps/GLES2

gtec_demo_framework: $(DEP_GTEC)
	@[ $${MACHINE:0:5} != imx8m -a $${MACHINE:0:5} != imx95 ] && exit || \
	 $(call download_repo,gtec_demo_framework,apps/gopoint) && \
	 $(call patch_apply,gtec_demo_framework,apps/gopoint) && \
	 \
	 $(call fbprint_b,"gtec_demo_framework") && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR) -L$(DESTDIR)/usr/lib" && \
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR) -L$(DESTDIR)/usr/lib" && \
	 export FEATURES="ConsoleHost,EarlyAccess,EGL,GoogleUnitTest,Lib_NlohmannJson,Lib_pugixml,Test_RequireUserInputToExit,WindowHost,G2D,OpenGLES2,OpenCV4,Vulkan1.2,OpenGLES3.2,OpenCL1.2,OpenVX1.2" && \
	 mv $(RFSDIR)/usr/bin/wayland-scanner $(RFSDIR)/usr/bin/wayland-scanner.bak && \
	 ln -sf /usr/bin/wayland-scanner $(RFSDIR)/usr/bin/wayland-scanner && \
	 \
	 cd $(GPDIR)/gtec_demo_framework && \
	 source ./prepare.sh && export DESTDIR='' && \
	 # *DESTDIR* is for compiling, it is not the *DESTDIR* of flexbuild && \
	 # FslBuild.py -vvvvv -c install --BuildThreads $(JOBS) --CMakeInstallPrefix . && \
	 # --UseFeatures [$${FEATURES}] --UseExtensions [$${EXTENSIONS}] --Variants [WindowSystem=$${WINDOW_SYSTEM}] && \
	 \
	 # Compiling GLES2 DemoApp && \
	 for demoapp in Bloom Blur EightLayerBlend FractalShader LineBuilder101 ModelLoaderBasics S03_Transform S04_Projection S06_Texturing S07_EnvMapping S08_EnvMappingRefraction ; do \
		cd $(GPDIR)/gtec_demo_framework/DemoApps/GLES2/$${demoapp}; \
		FslBuild.py --BuildThreads $(JOBS) --platform yocto --Variants [config=Release,FSL_GLES_NAME=vivante,WindowSystem=Wayland] --UseExtensions [$(EXT_GTEC)] --UseFeatures [$${FEATURES}] $(LOG_MUTE) ; \
		mkdir -p $(DESTDIR)/opt/imx-gpu-sdk/GLES2/$${demoapp}___Wayland/Content; \
		cp -arf $(GPNT_GPU_SOURDIR)/$${demoapp}___Wayland/Content/* $(DESTDIR)/$(GPNT_GPU_DESTDIR)/$${demoapp}___Wayland/Content/; \
		cp -arf $(GPNT_GPU_SOURDIR)/$${demoapp}___Wayland/GLES2.$${demoapp}___Wayland $(DESTDIR)/$(GPNT_GPU_DESTDIR)/$${demoapp}___Wayland/; \
	 done && \
	 \
	 mv $(RFSDIR)/usr/bin/wayland-scanner.bak $(RFSDIR)/usr/bin/wayland-scanner && \
	 $(call fbprint_d,"gtec_demo_framework")

# Copyright 2020-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# https://www.khronos.org/vulkan
# Vulkan Header files and API registry


vulkan_headers:
	@[ $(SOCFAMILY) != IMX ] && exit || \
	 $(call download_repo,vulkan_headers,apps/graphics) && \
	 $(call patch_apply,vulkan_headers,apps/graphics) && \
	 $(call fbprint_b,"vulkan_headers") && \
	 cd $(GRAPHICSDIR)/vulkan_headers && \
	 rm -rf build_$(DISTROTYPE)_$(ARCH) && \
	 mkdir -p build_$(DISTROTYPE)_$(ARCH) && \
	 cmake -S . -B build_$(DISTROTYPE)_$(ARCH) $(LOG_MUTE) && \
	 cmake --install build_$(DISTROTYPE)_$(ARCH) --prefix /usr $(LOG_MUTE) && \
	 $(call fbprint_d,"vulkan_headers")

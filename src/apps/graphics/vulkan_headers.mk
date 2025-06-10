# Copyright 2020-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# https://www.khronos.org/vulkan
# Vulkan Header files and API registry

repo_vulkan_headers_url=https://github.com/KhronosGroup/Vulkan-Headers.git
repo_vulkan_headers_commit=2bb0a23104ceffd9a2


vulkan_headers:
	@[ $(DESTARCH) != arm64 -o $(DISTROVARIANT) != desktop ] && exit || \
	 $(call fbprint_b,"vulkan_headers") && \
	 $(call repo-mngr,fetch,vulkan_headers,apps/graphics) && \
	 cd $(GRAPHICSDIR)/vulkan_headers && \
	 mkdir -p build_$(DISTROTYPE)_$(ARCH) && \
	 cmake -S . -B build_$(DISTROTYPE)_$(ARCH) $(LOG_MUTE) && \
	 cmake --install build_$(DISTROTYPE)_$(ARCH) --prefix /usr $(LOG_MUTE) && \
	 $(call fbprint_d,"vulkan_headers")

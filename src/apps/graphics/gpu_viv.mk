# Copyright 2017-2024,2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# GPU driver and demo test apps for Vivante GPU on i.MX and LS1028a platforms


gpu_viv:
	@$(call dl_by_wget,gpu_viv_bin,gpu_viv.bin)
	cd $(GRAPHICSDIR)
	if [ ! -d "$(GRAPHICSDIR)"/gpu_viv ]; then
		chmod +x $(FBDIR)/dl/gpu_viv.bin
		$(FBDIR)/dl/gpu_viv.bin --auto-accept --force $(LOG_MUTE)
		mv $(basename $(notdir $(repo_gpu_viv_bin_url))) gpu_viv
	fi
	$(call fbprint_b,"gpu_viv ")
	cd $(GRAPHICSDIR)/gpu_viv
	mkdir -p $(DESTDIR)/ $(RFSDIR)/
	cp -fa gpu-core/* $(DESTDIR)/
	cp -fa gpu-core/* $(RFSDIR)/
	ln -sf libvulkan_VSI.so $(DESTDIR)/usr/lib/libvulkan.so.1
	ln -sf libvulkan.so.1 $(DESTDIR)/usr/lib/libvulkan.so
	rm -f $(DESTDIR)/usr/lib/libGL.so*
	rm -f $(RFSDIR)/usr/lib/aarch64-linux-gnu/{libGLESv2.so,libGLESv2.so.2,libgbm.so.1,libvulkan.so,libvulkan.so.1,libEGL.so,libEGL.so.1}
	if [ -d gpu-tools ]; then cp -af gpu-tools/gmem-info/usr $(DESTDIR)/; fi
	if [ -d gpu-demos ]; then cp -af gpu-demos/opt $(DESTDIR)/; fi
	$(call fbprint_d,"gpu_viv")

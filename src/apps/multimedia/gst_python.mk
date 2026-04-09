# Copyright 2017-2024,2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


#gst_python:
gst_python: gstreamer gst_plugins_bad
	@$(call dl_by_wget,gst_python_tar,gst-python.tar.xz)
	if [ ! -d "$(MMDIR)"/gst_python ]; then
		mkdir -p $(MMDIR)/gst_python
		tar xf $(FBDIR)/dl/gst-python.tar.xz --strip-components=1 --wildcards -C $(MMDIR)/gst_python
	fi
	$(call fbprint_b,"gst_python")
	cd $(MMDIR)/gst_python
	sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
		-e 's%@DESTDIR@%$(DESTDIR)%g' $(FBDIR)/src/system/meson.cross > meson.cross
	rm -rf build
	export PYTHONPATH="$(RFSDIR)/usr/lib/python3.13/site-packages:$$PYTHONPATH"
	export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)"
	export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)"
	mkdir -p $(RFSDIR)/usr/lib
	cp -a $(DESTDIR)/usr/lib/libgstbase-1.0.so* \
		$(DESTDIR)/usr/lib/libgstanalytics-1.0.so* \
		$(RFSDIR)/usr/lib/
	mkdir -p $(RFSDIR)/usr/include/gstreamer-1.0/gst/analytics/
	cp -a $(DESTDIR)/usr/include/gstreamer-1.0/gst/analytics/* \
         $(RFSDIR)/usr/include/gstreamer-1.0/gst/analytics/
	meson setup build \
		-Dtests=disabled \
		-Dplugin=enabled \
		-Dlibpython-dir=$(RFSDIR)/usr/lib \
		--prefix=/usr \
		--buildtype=plain \
		--cross-file meson.cross \
		--libdir=lib \
		--wrap-mode=nodownload $(LOG_MUTE)
	ninja -j1 -C build install -v $(LOG_MUTE)
	mv $(DESTDIR)/usr/lib/python3/dist-packages/gi/overrides/_gi_gst_analytics.cpython-313-x86_64-linux-gnu.so \
		$(DESTDIR)/usr/lib/python3/dist-packages/gi/overrides/_gi_gst_analytics.cpython-313-aarch64-linux-gnu.so
	mv $(DESTDIR)/usr/lib/python3/dist-packages/gi/overrides/_gi_gst.cpython-313-x86_64-linux-gnu.so \
		$(DESTDIR)/usr/lib/python3/dist-packages/gi/overrides/_gi_gst.cpython-313-aarch64-linux-gnu.so
	$(call fbprint_d,"gst_python")

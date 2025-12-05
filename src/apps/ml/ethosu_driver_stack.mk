# Copyright 2023-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# The Linux driver stack for Arm(R) Ethos(TM)-U provides an example of how a rich operating system like Linux can
# dispatch inferences to an Arm Cortex(R)-M subsystem, consisting of an Arm Cortex-M of choice and an Arm Ethos-U NPU.

# depend: libflatbuffers-dev on target

# COMPATIBLE_MACHINE: imx93

PYTHON_SITEPACKAGES_DIR = "/usr/lib/python3/dist-packages"


ethosu_driver_stack: flatbuffers
	@[ $${MACHINE:0:5} != imx93  ] && exit || \
	 $(call download_repo,ethosu_driver_stack,apps/ml) && \
	 $(call patch_apply,ethosu_driver_stack,apps/ml) && \
	 $(call fbprint_b,"ethosu_driver_stack") && \
	 cd $(MLDIR)/ethosu_driver_stack && \
	 export CC="$(CROSS_COMPILE)gcc" && \
	 export CXX="$(CROSS_COMPILE)g++" && \
	 export LDFLAGS="--sysroot=$(RFSDIR) -L$(RFSDIR)/usr/lib" && \
	 export CPPFLAGS="--sysroot=$(RFSDIR) -I$(RFSDIR)/usr/include" && \
	 rm -rf build_$(DISTROTYPE)_$(ARCH) && \
	 mkdir -p build_$(DISTROTYPE)_$(ARCH)/dist && \
	 cmake  -S $(MLDIR)/ethosu_driver_stack \
		-B $(MLDIR)/ethosu_driver_stack/build_$(DISTROTYPE)_$(ARCH) $(LOG_MUTE) && \
	 $(MAKE) -j$(JOBS) -C build_$(DISTROTYPE)_$(ARCH) $(LOG_MUTE) && \
	 cmake --install build_$(DISTROTYPE)_$(ARCH) --prefix /usr --strip $(LOG_MUTE) && \
	 NO_FETCH_BUILD=1 \
	 STAGING_INCDIR=$(RFSDIR)/usr/include \
	 STAGING_LIBDIR=$(RFSDIR)/usr/lib \
	 python3 setup.py bdist_wheel --verbose --dist-dir build_$(DISTROTYPE)_$(ARCH)/dist build_ext \
		 --library-dirs build_$(DISTROTYPE)_$(ARCH)/driver_library $(LOG_MUTE) && \
	 mkdir -p $(DESTDIR)/$(PYTHON_SITEPACKAGES_DIR)/ethosu && \
	 cp build/lib.linux-*-cpython*/ethosu/interpreter.cpython-*-linux-gnu.so $(DESTDIR)/$(PYTHON_SITEPACKAGES_DIR)/ethosu && \
	 rename -f "s/x86_64/aarch64/" $(DESTDIR)/$(PYTHON_SITEPACKAGES_DIR)/ethosu/*.so && \
	 $(call fbprint_d,"ethosu_driver_stack")

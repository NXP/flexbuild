# Copyright 2023-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# The Linux driver stack for Arm(R) Ethos(TM)-U provides an example of how a rich operating system like Linux can
# dispatch inferences to an Arm Cortex(R)-M subsystem, consisting of an Arm Cortex-M of choice and an Arm Ethos-U NPU.

# depend: libflatbuffers-dev on target

# COMPATIBLE_MACHINE: imx93

PYTHON_SITEPACKAGES_DIR = "/usr/lib/python3.11/site-packages"


ethosu_driver_stack:
	@[ $(SOCFAMILY) != IMX -o $(DISTROVARIANT) = tiny -o $(DISTROVARIANT) = base ] && exit || \
	 $(call fbprint_b,"ethosu_driver_stack") && \
	 $(call repo-mngr,fetch,ethosu_driver_stack,apps/ml) && \
	 cd $(MLDIR)/ethosu_driver_stack && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)" && \
	 mkdir -p build_$(DISTROTYPE)_$(ARCH)/dist && \
	 cmake  -S $(MLDIR)/ethosu_driver_stack \
		-B $(MLDIR)/ethosu_driver_stack/build_$(DISTROTYPE)_$(ARCH) && \
	 $(MAKE) -j$(JOBS) -C build_$(DISTROTYPE)_$(ARCH) && \
	 cmake --install build_$(DISTROTYPE)_$(ARCH) --prefix /usr --strip && \
	 NO_FETCH_BUILD=1 \
	 STAGING_INCDIR=$(RFSDIR)/usr/include \
	 STAGING_LIBDIR=$(RFSDIR)/usr/lib \
	 python3 setup.py bdist_wheel --verbose --dist-dir build_$(DISTROTYPE)_$(ARCH)/dist build_ext \
		 --library-dirs build_$(DISTROTYPE)_$(ARCH)/driver_library && \
	 mkdir -p $(DESTDIR)/$(PYTHON_SITEPACKAGES_DIR)/ethosu && \
	 cp build/lib.linux-*-cpython*/ethosu/interpreter.cpython-*-linux-gnu.so $(DESTDIR)/$(PYTHON_SITEPACKAGES_DIR)/ethosu && \
	 rename "s/x86_64/aarch64/" $(DESTDIR)/$(PYTHON_SITEPACKAGES_DIR)/ethosu/*.so && \
	 $(call fbprint_d,"ethosu_driver_stack")

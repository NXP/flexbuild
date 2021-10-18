# Copyright 2019-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



armcl: dependency
ifeq ($(CONFIG_ARMCL), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu ] && exit || \
	 $(call fbprint_b,"Arm Compute Library") && \
	 $(call repo-mngr,fetch,armcl,apps/eiq) && \
	 cd $(eIQDIR)/armcl && \
	 scons arch=arm64-v8a neon=1 opencl=0 extra_cxx_flags="-fPIC" \
	       benchmark_tests=0 validation_tests=0 -j$(JOBS) && \
	 $(call fbprint_n,"Installing ARM Compute Library") && \
	 cp_args="-Prf --preserve=mode,timestamps --no-preserve=ownership" && \
	 cp $$cp_args arm_compute support include/half $(eIQDESTDIR)/usr/local/include && \
	 install -m 0755 build/libarm_compute*.so $(eIQDESTDIR)/usr/local/lib && \
	 find build/examples -type f -executable -exec cp -f {} $(eIQDESTDIR)/usr/local/bin/ \; && \
	 $(call fbprint_d,"armcl")
endif
endif

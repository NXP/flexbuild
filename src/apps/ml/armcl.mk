# Copyright 2019-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


armcl:
	@[ $(DESTARCH) != arm64 ] && exit || \
	 $(call fbprint_b,"Arm Compute Library") && \
	 $(call repo-mngr,fetch,armcl,apps/ml) && \
	 \
	 cd $(MLDIR)/armcl && \
	 scons arch=arm64-v8a neon=1 opencl=0 \
	 	build=cross_compile os=linux \
		extra_cxx_flags='-fPIC -Wno-error=strict-overflow -Wno-error=array-bounds ' \
		benchmark_tests=0 validation_tests=0 \
		cppthreads=1 examples=1 \
		benchmark_tests=0 validation_tests=0 \
		Werror=0 debug=0 embed_kernels=0 \
		-j$(JOBS) && \
	 $(call fbprint_n,"Installing ARM Compute Library") && \
	 cp_args="-Prf --preserve=mode,timestamps --no-preserve=ownership" && \
	 cp $$cp_args arm_compute support include/half $(DESTDIR)/usr/include && \
	 install -m 0755 build/{libarm_compute*.so,libarm_compute*.a} $(DESTDIR)/usr/lib && \
	 find build/examples -type f -executable -exec cp -f {} $(DESTDIR)/usr/local/bin/ \; && \
	 $(call fbprint_d,"armcl")

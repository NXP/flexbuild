# Copyright 2023-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# Reqiuires arm-ran-acceleration-library be manually downloaded and untared

# Default to 'n' if not provided by the environment or command line
CONFIG_APP_FH_ECPRI ?= n

fh_ecpri:
	@set -e; \
	if [ "$(strip $(CONFIG_APP_FH_ECPRI))" != "y" ]; then \
		echo "Skipping fh_ecpri: CONFIG_APP_FH_ECPRI!='y' (current='$(strip $(CONFIG_APP_FH_ECPRI))')"; \
		exit 0; \
	fi && \
	$(call download_repo,fh_ecpri,apps/networking,git) && \
	$(call fbprint_b,"fh_ecpri") && \
	if [ ! -d $(NETDIR)/gtest-1.7.0 ]; then  \
		cd $(NETDIR) && wget --no-check-certificate $(repo_gtest_url) && unzip release-1.7.0 && \
		rm -rf release-1.7.0 && mv googletest-release-1.7.0 gtest-1.7.0 && cd $(NETDIR)/gtest-1.7.0 && \
		$(CROSS_COMPILE)g++ -isystem include -I $(NETDIR)/gtest-1.7.0 -lpthread -c src/gtest-all.cc && \
		$(CROSS_COMPILE)ar -rv libgtest.a gtest-all.o && cd build-aux && cmake .. && make && cd .. && \
		ln -s build-aux/libgtest_main.a libgtest_main.a; \
	fi && \
	if [ ! -f $(RFSDIR)/usr/include/armral.h ]; then  \
		bld arm_ral -m $(MACHINE) -f $(CFGLISTYML);  \
	fi && \
	test -d $(NETDIR)/arm_ral || { $(call fbprint_e,"fh_ecpri requires apps/networking/arm_ral") && exit 1;} && \
	if [ ! -d $(DESTDIR)/usr/local/dpdk ]; then \
		bld dpdk -m $(MACHINE) -f $(CFGLISTYML);  \
	fi && \
	cd $(NETDIR)/fh_ecpri/fhi_lib && \
	export CROSS=$(CROSS_COMPILE) && \
	export ARCH=arm64 && export OPENSSL_PATH=$(RFSDIR)/usr && \
	export XRAN_DIR=$(NETDIR)/fh_ecpri/fhi_lib && \
	export RTE_SDK=$(NETDIR)/dpdk && export RTE_TARGET=build_$(DISTROTYPE)_arm64 && \
	export RTE_INC=$(DESTDIR)/usr/include && \
	export ARM_RANLIB_PATH=$(RFSDIR)/usr/ && \
	export PKG_CONFIG_PATH=$(DESTDIR)/usr/local/lib/pkgconfig:$(RFSDIR)/usr/lib/pkgconfig:$(PKG_CONFIG_PATH) && \
	export PKG_CONFIG_LIBDIR=$(PKG_CONFIG_LIBDIR):$(DESTDIR)/usr/local/lib:$(RFSDIR)/usr/lib && \
	export EXTRA_LIBS="$(shell PKG_CONFIG_PATH=$(DESTDIR)/usr/lib/pkgconfig $(CROSS)pkg-config --static --libs libdpdk)"&& \
	export LD_FLAGS="-L$(DESTDIR)/usr/lib -L$(RFSDIR)/usr/lib -L$(RFSDIR)/lib/aarch64-linux-gnu --sysroot=$(RFSDIR)" && \
	export GTEST_ROOT=$(NETDIR)/gtest-1.7.0 && \
	export BUILD_GCC=1 && ./build.sh DFE_APP $(LOG_MUTE) && \
	mkdir -p $(DESTDIR)/usr/local/dpdk/fh_ecpri && cp -f $(NETDIR)/fh_ecpri/fhi_lib/app/build/sample-app ${DESTDIR}/usr/local/bin/fhi-sample-app && \
	cp -r $(NETDIR)/fh_ecpri/fhi_lib/app/usecase ${DESTDIR}/usr/local/dpdk/fh_ecpri && \
	rm -r ${DESTDIR}/usr/local/dpdk/fh_ecpri/usecase/conf/emulator && \
	cp -f $(NETDIR)/fh_ecpri/fhi_lib/readme_nxp.txt ${DESTDIR}/usr/local/dpdk/fh_ecpri && \
	$(CROSS_COMPILE)strip $(NETDIR)/fh_ecpri/fhi_lib/test/test_xran/unittests && \
	cp -f $(NETDIR)/fh_ecpri/fhi_lib/test/test_xran/{unittests,conf.json} ${DESTDIR}/usr/local/dpdk/fh_ecpri/ && \
	cp -f $(NETDIR)/fh_ecpri/script/ru3a-env.rc ${DESTDIR}/root && \
	$(call fbprint_d,"fh_ecpri")

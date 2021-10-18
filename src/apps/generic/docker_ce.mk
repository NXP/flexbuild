# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


docker_ce_bin_url ?= https://www.nxp.com/lgfiles/sdk/lsdk2108/docker-ce-bin-v18.09.6.tar.gz


docker_ce:
ifeq ($(CONFIG_DOCKER_CE), "y")
ifeq ($(DISTROTYPE), ubuntu)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = lite -o $(DISTROSCALE) = desktop ] && exit || \
	 $(call fbprint_b,"docker_ce") && \
	 if [ ! -d $(GENDIR)/docker_ce ]; then \
	     mkdir -p $(GENDIR)/docker_ce && cd $(GENDIR)/docker_ce && \
	     wget -q $(docker_ce_bin_url) && tar xf docker-ce-bin-v18.09.6.tar.gz --strip-components 1; \
	 fi && \
	 if [ $(DESTARCH) = arm32 ]; then \
	     tarch=armhf; \
	 else \
	     tarch=$(DESTARCH); \
	 fi && \
	 if [ -f $(RFSDIR)/usr/bin/dockerd-ce ]; then \
	     $(call fbprint_n,"docker-ce was already installed") && exit; \
	 fi && \
	 if [ ! -d $(RFSDIR)/lib ]; then \
	     bld -i mkrfs -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 if [ $(DISTROTYPE) = ubuntu -a $(DISTROSCALE) != lite -a -d $(GENDIR)/docker_ce ]; then \
	     sudo cp -f $(GENDIR)/docker_ce/containerd/containerd.io_1.2.4_$${tarch}.deb $(RFSDIR) && \
	     sudo cp -f $(GENDIR)/docker_ce/docker-ce/ubuntu-bionic/$$tarch/*.deb $(RFSDIR) && \
	     sudo chroot $(RFSDIR) dpkg -i containerd.io_1.2.4_$${tarch}.deb && \
	     sudo chroot $(RFSDIR) dpkg -i docker-ce-cli_v18.09.6-ubuntu-bionic_$${tarch}.deb && \
	     sudo chroot $(RFSDIR) dpkg -i docker-ce_v18.09.6-ubuntu-bionic_$${tarch}.deb && \
	     sudo rm -f $(RFSDIR)/*.deb && $(call fbprint_d,"docker_ce"); \
	 fi
endif
endif

# Copyright 2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# ROS (Robot Operating System) provides libraries and tools to help software developers create robot applications.
# It provides hardware abstraction, device drivers, libraries, visualizers, message-passing, package management, and more.
# ROS is licensed under an open source, BSD license.


# Cross installing ROS 1 and/or 2 to target arm64 Ubuntu focal rootfs


# ros: ros1 ros2
ros: ros2


ros1:
ifneq ($(CONFIG_ROS)$(FORCE), "n")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) != desktop ] && exit || \
	 if [ -f $(RFSDIR)/opt/ros/noetic/bin/roscore ]; then \
	     $(call fbprint_n,"ROS was already installed in $(RFSDIR)/opt/ros") && exit; \
	 fi && \
	 if [ ! -d $(RFSDIR)/usr/lib/aarch64-linux-gnu ]; then \
	     bld -i mkrfs -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 $(call fbprint_b,"ROS1") && \
	 sudo chroot $(RFSDIR) curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -; \
	 [ -n "$(http_proxy)" ] && proxyopt="http-proxy=$(http_proxy)" || proxyopt=""; \
	 sudo chroot $(RFSDIR) apt-key adv --keyserver-options $$proxyopt \
	      --keyserver keyserver.ubuntu.com --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654; \
	 sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu focal main" > $(RFSDIR)/etc/apt/sources.list.d/ros-latest.list'; \
	 sudo chroot $(RFSDIR) apt update && \
	 if [ $(DISTROSCALE) = desktop ]; then \
	     sudo chroot $(RFSDIR) apt install -y ros-noetic-desktop-full; \
	 else \
	     sudo chroot $(RFSDIR) apt install -y ros-noetic-ros-base; \
	 fi && \
	 $(call fbprint_d,"ROS1 in $(RFSDIR)/opt/ros")
endif
else
	@$(call fbprint_w,INFO: ROS is not enabled by default in configs/$(CFGLISTYML))
endif






ros2:
ifneq ($(CONFIG_ROS)$(FORCE), "n")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) != desktop ] && exit || \
	 if [ -f $(RFSDIR)/opt/ros/foxy/bin/ros2 ]; then \
	     $(call fbprint_n,"ROS was already installed in $(RFSDIR)/opt/ros") && exit; \
	 fi && \
	 if [ ! -d $(RFSDIR)/usr/lib/aarch64-linux-gnu ]; then \
	     bld -i mkrfs -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 $(call fbprint_b,"ROS2") && \
	 sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o  $(RFSDIR)/usr/share/keyrings/ros-archive-keyring.gpg; \
	 echo "deb [arch=$(DESTARCH) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu focal main" | \
	      sudo tee $(RFSDIR)/etc/apt/sources.list.d/ros2.list > /dev/null; \
	 sudo chroot $(RFSDIR) apt update && \
	 if [ $(DISTROSCALE) = desktop ]; then \
	     sudo chroot $(RFSDIR) apt install -y ros-foxy-desktop; \
	 else \
	     sudo chroot $(RFSDIR) apt install -y ros-foxy-ros-base; \
	 fi && \
	 $(call fbprint_d,"ROS2 in $(RFSDIR)/opt/ros")
endif
endif

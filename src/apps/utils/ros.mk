# Copyright 2021-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# ROS (Robot Operating System) provides libraries and tools to help software developers create robot applications.
# It provides hardware abstraction, device drivers, libraries, visualizers, message-passing, package management, and more.
# ROS is licensed under an open source, BSD license.

# https://docs.ros.org

# Cross installing ROS2 to target arm64 Debian rootfs


ros:
ifeq ($(CONFIG_ROS), "y")
	@[ $(DISTROVARIANT) = base ] && exit || \
	 if [ -f $(RFSDIR)/opt/ros/foxy/bin/ros2 ]; then \
	     $(call fbprint_n,"ROS was already installed in $(RFSDIR)/opt/ros") && exit; \
	 fi && \
	 if [ ! -d $(RFSDIR)/usr/lib/aarch64-linux-gnu ]; then \
	     bld rfs -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 $(call fbprint_b,"ROS2") && \
	 sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o  $(RFSDIR)/usr/share/keyrings/ros-archive-keyring.gpg; \
	 echo "deb [arch=$(DESTARCH) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu focal main" | \
	      sudo tee $(RFSDIR)/etc/apt/sources.list.d/ros2.list > /dev/null; \
	 sudo chroot $(RFSDIR) apt update && \
	 if [ $(DISTROVARIANT) = desktop ]; then \
	     sudo chroot $(RFSDIR) apt install -y ros-foxy-desktop; \
	 else \
	     sudo chroot $(RFSDIR) apt install -y ros-foxy-ros-base; \
	 fi && \
	 $(call fbprint_d,"ROS2 in $(RFSDIR)/opt/ros")
endif

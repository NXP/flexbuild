# Copyright 2023-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# ROS (Robot Operating System) provides libraries and tools to help software developers create robot applications.
# It provides hardware abstraction, device drivers, libraries, visualizers, message-passing, package management, and more.
# ROS is licensed under an open source, BSD license.

# https://docs.ros.org

# Cross installing ROS2 for target arm64 Debian rootfs


ros:
ifeq ($(CONFIG_ROS), "y")
	@[ $(DISTROVARIANT) = base ] && exit || \
	 if [ -d $(RFSDIR)/opt/ros2_jazzy ]; then \
	     $(call fbprint_n,"ROS was already installed in $(RFSDIR)/opt/ros2_jazzy") && exit; \
	 fi && \
	 if [ ! -d $(RFSDIR)/usr/lib/aarch64-linux-gnu ]; then \
	     bld rfs -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 $(call fbprint_b,"ROS2") && \
	 sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o $(RFSDIR)/usr/share/keyrings/ros-archive-keyring.gpg && \
	 echo "deb [arch=arm64 signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu bookworm main" | \
	       sudo tee $(RFSDIR)/etc/apt/sources.list.d/ros2.list > /dev/null && \
	 sudo chroot $(RFSDIR) apt update && \
	 sudo chroot $(RFSDIR) apt install -y \
	 python3-flake8-blind-except \
	 python3-flake8-class-newline \
	 python3-flake8-deprecated \
	 python3-mypy \
	 python3-pip \
	 python3-pytest \
	 python3-pytest-cov \
	 python3-pytest-mock \
	 python3-pytest-repeat \
	 python3-pytest-rerunfailures \
	 python3-pytest-runner \
	 python3-pytest-timeout \
	 ros-dev-tools && \
	 sudo mkdir -p $(RFSDIR)/opt/ros2_jazzy/src && \
	 $(call fbprint_d,"ROS2 Jazzy in $(RFSDIR)/opt/ros2_jazzy")
endif

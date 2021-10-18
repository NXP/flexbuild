#!/bin/bash
#
# Copyright 2018 NXP
#
# SPDX-License-Identifier:      BSD-3-Clause
#
# reconfigure default setting



# automatically load the specified module during booting up
echo mali-dp >> /etc/modules
echo imx8-media-dev >> /etc/modules

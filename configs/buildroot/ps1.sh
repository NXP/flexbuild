#!/bin/bash
#
# Copyright 2018 NXP
#
# SPDX-License-Identifier:      BSD-3-Clause


if [ "`id -u`" -eq 0 ]; then
        export PS1="[\u@\h \W]\# "
else
        export PS1="[\u@\h \W]\$ "
fi

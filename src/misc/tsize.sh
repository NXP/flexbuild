#!/bin/bash
#
# Copyright 2019 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
# This script queries terminal for current window size and does a stty
# to set rows and columns to that size.  It is useful for terminals that
# are confused about size.  This often happens when accessing consoles
# via a serial port.

if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    exit
fi
orig=$(stty -g)
stty cbreak -echo min 0 time 8
printf '\033[18t' > /dev/tty
IFS='[;t'
read _ char2 rows cols < /dev/tty
[[ "$char2" == "8" ]] || { stty "$orig" ; exit ; }
stty "$orig"
if [ `awk -v string="$cols" 'BEGIN { print length(string)'}` -gt 3 ]; then
    exit
fi
stty rows "$rows" columns "$cols"

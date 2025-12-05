#
# Copyright 2017-2025 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
# Author: Andy Tang <andy.tang@nxp.com>
#

red=\e[0;41m
RED=\e[1;31m
green=\e[0;32m
GREEN=\e[1;32m
yellow=\e[5;43m
YELLOW=\e[1;33m
NC=\e[0m

define fbprint_b
        echo -e "$(green)Building $1  $(NC)"
endef
define fbprint_n
	echo -e "$(green)$1 $(NC)"
endef
define fbprint_d
	echo -e "$(GREEN)$1  [Done] \n $(NC)"
endef
define fbprint_w
        echo -e "$(YELLOW)$1 $(NC)"
endef
define fbprint_e
        echo -e "$(red)$1 $(NC)"
endef

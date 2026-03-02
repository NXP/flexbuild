#
# Copyright 2017-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
# Author: Andy Tang <andy.tang@nxp.com>
#

# Colors
# SGR attributes: 0=reset, 1=bold, 2=dim, 4=underline, 5=blink, 7=reverse
RESET  := \\033[0m
NC     := \\033[0m

red     := \\033[0;31m
green   := \\033[0;32m
yellow  := \\033[0;33m
blue    := \\033[0;34m
purple  := \\033[0;35m
cyan    := \\033[0;36m
white   := \\033[0;37m

RED     := \\033[1;31M
GREEN   := \\033[1;32m
YELLOW  := \\033[1;33m
BLUE    := \\033[1;34m
PURPLE  := \\033[1;35m
CYAN    := \\033[1;36m
WHITE   := \\033[1;37m

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

FB_OUT  = printf "[INFO] %s\n" "$(1)"
FB_INFO  = printf "$(GREEN)[INFO] %s$(RESET)\n" "$(1)"
FB_BUILDING = printf "$(green)Building %s$(RESET)\n" "$(1)"
FB_DONE = printf "$(GREEN)%s [Done]$(RESET)\n" "$(1)"
FB_WARN  = printf "$(YELLOW)[WARN] %s$(RESET)\n" "$(1)"
FB_ERROR = printf "$(red)[ERROR] %s$(RESET)\n" "$(1)"
FB_DEBUG = $(if $(filter 3,$(LOG_LEVEL)), @printf "$(BLUE)[DEBUG] %s$(RESET)\n" "$(1)", @:)


LOG_TIMESTAMP := $(shell date +%Y%m%d%H%M%S)
BUILD_LOG := $(FBDIR)/logs/build_$(LOG_TIMESTAMP).log
define set_loglevel
  $(if $(filter 0,$(strip $(LOG_LEVEL))), \
    $(eval LOG_MUTE := ), \
  $(if $(filter 1,$(strip $(LOG_LEVEL))), \
    $(eval LOG_MUTE := >/dev/null), \
  $(if $(filter 2,$(strip $(LOG_LEVEL))), \
    $(eval LOG_MUTE := >/dev/null 2>&1), \
  $(if $(filter 3,$(strip $(LOG_LEVEL))), \
    $(eval LOG_MUTE := 2>&1  | tee -a $(BUILD_LOG) > /dev/null), \
    $(error Error: LOG_LEVEL must be 0, 1, 2 or 3) \
  ))))
endef
$(call set_loglevel)

.SHELLFLAGS := $(if $(strip $(MKDEBUG)),-ex -o pipefail -c,-ec)

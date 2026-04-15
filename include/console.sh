#!/bin/bash
#
# Copyright 2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
# logging and output utilities
#

# Color definitions
red='\e[0;41m'
RED='\e[1;31m'
GREEN='\e[1;32m'
green='\e[0;32m'
yellow='\e[5;43m'
YELLOW='\e[1;33m'
NC='\e[0m'

# Logging functions with color output
fbprint_e() {
    echo -e "${RED}$1 ${NC}"
}

fbprint_n() {
    echo -e "${green}\n$1 ${NC}"
}

fbprint_w() {
    echo -e "${YELLOW}$1 ${NC}"
}

fbprint_d() {
    echo -e "${GREEN}$1     [Done] ${NC}"
}

# Log level control functions
# LOG_LEVEL: 0=verbose, 1=quiet stdout, 2=quiet all
log_mute() {
  case "${LOG_LEVEL:-2}" in
    0)
      "$@"
      ;;
    1)
      "$@" >/dev/null
      ;;
    2)
      "$@" >/dev/null 2>&1 || {
        echo "Error: Command '$*' failed. Please export LOG_LEVEL=0 and retry."
        exit 1
      }
      ;;
    *)
      echo "Error LOG_LEVEL must be 0, 1 or 2" >&2
      exit 1
      ;;
  esac
}

# Show output one line at a time (useful for progress indicators)
show_one_line() {
  case "${LOG_LEVEL:-2}" in
    0)
      "$@"
      ;;
    1)
      "$@" >/dev/null
      ;;
    2)
      echo
      "$@" 2>&1 | while IFS= read -r line; do
        printf "\033[1A\033[2K\r%s\n" "$line"
      done
      ;;
    *)
      echo "Error LOG_LEVEL must be 0, 1 or 2" >&2
      exit 1
      ;;
  esac
}

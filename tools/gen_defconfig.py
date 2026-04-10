#!/usr/bin/env python3
import sys
import glob
from kconfiglib import Kconfig


def die(msg):
    print(f"ERROR: {msg}", file=sys.stderr)
    sys.exit(1)


def load_board_conf(board):
    for path in glob.glob("configs/board/*.conf"):
        data = {}
        with open(path) as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                if "=" in line:
                    k, v = line.split("=", 1)
                    data[k.strip()] = v.strip()
        if data.get("machine") == board:
            return data
    return None


if len(sys.argv) != 3:
    die("usage: gen_defconfig.py <Kconfig> <board-name>")

kconfig_path = sys.argv[1]
board = sys.argv[2]

conf = load_board_conf(board)
if not conf:
    die(f"Board '{board}' not found in configs/board")

soc = conf.get("kconfig_soc")
if not soc:
    die(f"Board '{board}' does not define kconfig_soc")

kconf = Kconfig(kconfig_path)

sym = kconf.syms.get(soc)
if not sym:
    die(f"{soc} not found in Kconfig")

sym.set_value(2)   # y

kconf.write_config(".config")

print(f"Generated .config for board '{board}' ({soc}=y)")

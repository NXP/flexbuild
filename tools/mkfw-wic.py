#!/usr/bin/env python3
"""
mkfw-wic.py - Create bootable firmware WIC images for NXP i.MX / Layerscape platforms.

This tool creates a minimal bootable WIC image containing:
  - MBR partition table
  - BSP composite firmware (at SoC-specific offset)
  - Optional ITB image (for i.MX lsdk26* and later)
  - Empty partition placeholder

NOTE: This does NOT include rootfs or boot partition images.
      For full system installation, use flex-installer after flashing this firmware WIC.

Works on Windows, Linux, and macOS with pure Python 3 (no external dependencies).

Image composition rules:
  Layerscape (all versions):        firmware_<machine>_sdboot.img only
  i.MX + lsdk24*/lsdk25*:          firmware_<machine>_sdboot.img only (ITB included)
  i.MX + lsdk26* and later:        <machine>-sd-flash.bin + <ver>_poky_tiny_IMX_arm64.itb
  i.MX + before lsdk24*:           NOT SUPPORTED

Usage examples:
  python mkfw-wic.py -m imx8mpevk -v lsdk2606          # i.MX lsdk26*: flash.bin + itb
  python mkfw-wic.py -m imx8mpevk -v lsdk2512          # i.MX lsdk25*: firmware only
  python mkfw-wic.py -m ls1046ardb -v lsdk2606         # LS: firmware only
  python mkfw-wic.py --list
"""

import argparse
import os
import sys
import struct
import urllib.request
import shutil
import re

# ─── Constants ───────────────────────────────────────────────────────────────

TOOL_VERSION = "1.5.0"
TOOL_NAME = "mkfw-wic"
SECTOR_SIZE = 512
KiB = 1024
MiB = 1024 * 1024

DEFAULT_VERSION = "lsdk2606"
DEFAULT_BASE_URL = "https://www.nxp.com/lgfiles/sdk"

# ITB offset: 0x4000 in 1K-block units = 16 MiB byte offset
DEFAULT_ITB_OFFSET_KB = 0x4000
DEFAULT_ITB_OFFSET_BYTES = DEFAULT_ITB_OFFSET_KB * KiB  # 16 MiB

# Extra padding at end of WIC image
MIN_WIC_PAD_MiB = 1

# i.MX SDK version support:
# - lsdk24*, lsdk25*: firmware_<machine>_sdboot.img (ITB included)
# - lsdk26* and later: <machine>-sd-flash.bin + ITB
# - before lsdk24*: NOT SUPPORTED
IMX_MIN_SUPPORTED_VERSION = 2400  # lsdk2400

# ─── Machine definitions ────────────────────────────────────────────────────

LS_MACHINES = [
    "ls1028ardb", "ls1043ardb", "ls1046ardb", "lx2160ardb", "la1224rdb",
]

IMX_MACHINES = [
    "imx8mmevk", "imx8mpevk", "imx8mpfrdm", "imx8qmmek",
    "imx91evk", "imx91frdm", "imx91sfrdm",
    "imx93evk", "imx93frdm",
    "imx95-15x15-frdm", "imx95-15x15-evk",
    "imx95-19x19-frdm-pro", "imx95-19x19-evk",
]

ALL_MACHINES = LS_MACHINES + IMX_MACHINES

# Firmware byte offsets (longest-prefix-first)
FIRMWARE_OFFSET_MAP = [
    ("imx8mq", 33 * KiB),
    ("imx8mm", 33 * KiB),
    ("imx8mp", 32 * KiB),
    ("imx8mn", 32 * KiB),
    ("imx8qm", 32 * KiB),
    ("imx8qx", 32 * KiB),
    ("imx8",   32 * KiB),
    ("imx91",  32 * KiB),
    ("imx93",  32 * KiB),
    ("imx95",  32 * KiB),
    ("imx9",   32 * KiB),
    ("imx6",   1  * KiB),
    ("imx7",   1  * KiB),
    ("ls",     4  * KiB),
    ("lx",     4  * KiB),
    ("la",     4  * KiB),
]


# ─── Platform / version logic ───────────────────────────────────────────────

def is_layerscape(machine: str) -> bool:
    return any(machine.startswith(p) for p in ("ls", "lx", "la"))


def extract_version_number(version: str) -> int:
    """
    Extract numeric version from SDK version string.
    Examples:
      lsdk2606 -> 2606
      lsdk2512 -> 2512
      lsdk2312 -> 2312
      lsdk2406 -> 2406
    Returns 0 if cannot parse.
    """
    match = re.search(r'lsdk(\d{4})', version.lower())
    if match:
        return int(match.group(1))
    return 0


def check_imx_version_support(machine: str, version: str) -> None:
    """
    Check if i.MX version is supported (>= lsdk2400).
    Raises SystemExit if not supported.
    Only checks for i.MX platforms.
    """
    if is_layerscape(machine):
        return  # Layerscape supports all versions
    
    ver_num = extract_version_number(version)
    
    if ver_num == 0:
        raise SystemExit(
            f"ERROR: Cannot parse SDK version '{version}'.\n"
            f"  Expected format: lsdkYYMM (e.g., lsdk2606, lsdk2512)"
        )
    
    if ver_num < IMX_MIN_SUPPORTED_VERSION:
        raise SystemExit(
            f"ERROR: i.MX platform does not support SDK version '{version}' (version number: {ver_num}).\n"
            f"  Minimum supported version: lsdk2400 (lsdk24*)\n"
            f"  Supported versions: lsdk24*, lsdk25*, lsdk26* and later\n"
            f"  Your version '{version}' is too old."
        )


def needs_separate_itb(machine: str, version: str) -> bool:
    """
    Determine whether a separate ITB file is needed.
      - Layerscape: NEVER (all versions, firmware includes everything)
      - i.MX + lsdk24*/lsdk25*: NO (firmware already includes ITB)
      - i.MX + lsdk26* and later: YES (need separate ITB)
      - i.MX + before lsdk24*: NOT SUPPORTED (will error earlier)
    """
    if is_layerscape(machine):
        return False
    
    # i.MX: check version
    ver_num = extract_version_number(version)
    
    # lsdk24* (2400-2499), lsdk25* (2500-2599) -> ITB included
    if 2400 <= ver_num < 2600:
        return False
    
    # lsdk26* (2600+) -> need separate ITB
    return True


def get_firmware_offset(machine: str) -> int:
    for prefix, offset in FIRMWARE_OFFSET_MAP:
        if machine.startswith(prefix):
            return offset
    return 4 * KiB


def firmware_filename(machine: str, version: str) -> str:
    """
    Determine firmware filename based on machine and SDK version.
    
    Layerscape (all versions):
      -> firmware_<machine>_sdboot.img
    
    i.MX:
      lsdk24*, lsdk25* (2400-2599) -> firmware_<machine>_sdboot.img
      lsdk26* and later (2600+)    -> <machine>-sd-flash.bin
      before lsdk24* (<2400)       -> NOT SUPPORTED (error raised earlier)
    """
    if is_layerscape(machine):
        return f"firmware_{machine}_sdboot.img"
    
    # i.MX: check version for naming convention
    ver_num = extract_version_number(version)
    
    # lsdk24* (2400-2499), lsdk25* (2500-2599)
    if 2400 <= ver_num < 2600:
        return f"firmware_{machine}_sdboot.img"
    
    # lsdk26* (2600+)
    return f"{machine}-sd-flash.bin"


def itb_filename(version: str) -> str:
    return f"{version}_poky_tiny_IMX_arm64.itb"


def align_up(value: int, alignment: int) -> int:
    return ((value + alignment - 1) // alignment) * alignment


def human_size(n: int) -> str:
    if n >= MiB:
        return f"{n / MiB:.1f} MiB"
    if n >= KiB:
        return f"{n / KiB:.1f} KiB"
    return f"{n} B"


# ─── Download ────────────────────────────────────────────────────────────────

def download_file(url: str, dest: str) -> str:
    if os.path.isfile(dest):
        print(f"  [skip] {os.path.basename(dest)} already exists locally")
        return dest

    print(f"  Downloading {url}")
    print(f"         -> {dest}")

    def _reporthook(block_num, block_size, total_size):
        downloaded = block_num * block_size
        if total_size > 0:
            pct = min(100.0, downloaded * 100.0 / total_size)
            filled = int(40 * pct / 100)
            bar = '#' * filled + '-' * (40 - filled)
            sys.stdout.write(
                f"\r  |{bar}| {pct:5.1f}%  "
                f"{human_size(downloaded)} / {human_size(total_size)}  "
            )
        else:
            sys.stdout.write(f"\r  Downloaded {human_size(downloaded)}  ")
        sys.stdout.flush()

    try:
        urllib.request.urlretrieve(url, dest, reporthook=_reporthook)
        print()
    except Exception as exc:
        print()
        if os.path.exists(dest):
            os.remove(dest)
        raise SystemExit(f"ERROR: Failed to download {url}\n  {exc}")

    return dest


# ─── WIC image creation ─────────────────────────────────────────────────────

def write_at(fobj, offset: int, data: bytes):
    fobj.seek(offset)
    fobj.write(data)


def copy_file_at(fobj, offset: int, src_path: str):
    fobj.seek(offset)
    with open(src_path, "rb") as src:
        shutil.copyfileobj(src, fobj, length=4 * MiB)


def build_mbr(partitions):
    mbr = bytearray(512)
    for idx, (start, size, ptype, bootable) in enumerate(partitions[:4]):
        entry = bytearray(16)
        entry[0] = 0x80 if bootable else 0x00
        entry[1], entry[2], entry[3] = 0xFE, 0xFF, 0xFF
        entry[4] = ptype
        entry[5], entry[6], entry[7] = 0xFE, 0xFF, 0xFF
        struct.pack_into("<I", entry, 8,  start // SECTOR_SIZE)
        struct.pack_into("<I", entry, 12, size  // SECTOR_SIZE)
        mbr[446 + idx * 16 : 446 + idx * 16 + 16] = entry
    mbr[510] = 0x55
    mbr[511] = 0xAA
    return bytes(mbr)


def create_wic_single(firmware_path: str, machine: str, version: str,
                      output: str):
    """
    Single-file WIC: firmware only (Layerscape all versions, i.MX lsdk24*/25*).
    WIC = MBR + firmware at SoC-specific offset.
    """
    fw_offset = get_firmware_offset(machine)
    fw_size = os.path.getsize(firmware_path)
    image_size = align_up(fw_offset + fw_size + MIN_WIC_PAD_MiB * MiB, MiB)

    part_start = align_up(fw_offset + fw_size, MiB)
    part_size = image_size - part_start
    if part_size <= 0:
        part_size = MiB
        image_size = part_start + part_size

    platform = "Layerscape" if is_layerscape(machine) else "i.MX"

    print()
    print("=" * 65)
    print(f"  Creating firmware WIC for {platform}: {machine} ({version})")
    print(f"  Mode: single firmware (ITB included in firmware)")
    print("=" * 65)
    print(f"  Firmware : {firmware_path} ({human_size(fw_size)})")
    print(f"  FW offset: {fw_offset:#x} ({human_size(fw_offset)})")
    print(f"  WIC size : {human_size(image_size)}")
    print(f"  Output   : {output}")
    print("=" * 65)

    mbr_data = build_mbr([(part_start, part_size, 0x83, True)])

    with open(output, "wb") as f:
        f.seek(image_size - 1)
        f.write(b"\x00")
        write_at(f, 0, mbr_data)
        print("\n  Writing firmware ...")
        copy_file_at(f, fw_offset, firmware_path)
        f.flush()

    final_size = os.path.getsize(output)
    print(f"\n  Firmware WIC created: {output} ({human_size(final_size)})")

    print()
    print("  SD Card Layout:")
    print("  +------------------------------------------------------------+")
    print(f"  | 0x{0:08X}  MBR (512 bytes)                              |")
    print(f"  | 0x{fw_offset:08X}  firmware ({human_size(fw_size):>10s})                    |")
    print(f"  | 0x{part_start:08X}  Partition 1 ({human_size(part_size):>10s})                 |")
    print(f"  | 0x{image_size:08X}  End ({human_size(image_size):>10s})                       |")
    print("  +------------------------------------------------------------+")

    _print_flash_instructions(output)


def create_wic_with_itb(firmware_path: str, itb_path: str, machine: str,
                        version: str, output: str, itb_offset: int):
    """
    Two-file WIC: firmware + ITB (i.MX with lsdk26* and later).
    firmware -> SoC-specific offset
    ITB      -> itb_offset bytes (default 16 MiB)
    """
    fw_offset = get_firmware_offset(machine)
    fw_size   = os.path.getsize(firmware_path)
    itb_size  = os.path.getsize(itb_path)

    fw_end  = fw_offset + fw_size
    itb_end = itb_offset + itb_size
    if itb_offset < fw_end:
        raise SystemExit(
            f"ERROR: ITB offset ({itb_offset:#x}) overlaps firmware region "
            f"({fw_offset:#x} .. {fw_end:#x}).\n"
            f"  Firmware ends at {human_size(fw_end)}. "
            f"Use a larger --itb-offset value."
        )

    image_size = align_up(itb_end + MIN_WIC_PAD_MiB * MiB, MiB)

    part_start = align_up(itb_end, MiB)
    part_size  = image_size - part_start
    if part_size <= 0:
        part_size = MiB
        image_size = part_start + part_size

    print()
    print("=" * 65)
    print(f"  Creating firmware WIC for i.MX: {machine} ({version})")
    print(f"  Mode: firmware + separate ITB")
    print("=" * 65)
    print(f"  Firmware  : {firmware_path} ({human_size(fw_size)})")
    print(f"  FW offset : {fw_offset:#x} ({human_size(fw_offset)})")
    print(f"  ITB image : {itb_path} ({human_size(itb_size)})")
    print(f"  ITB offset: {itb_offset:#x} ({human_size(itb_offset)})")
    print(f"  WIC size  : {human_size(image_size)}")
    print(f"  Output    : {output}")
    print("=" * 65)

    mbr_data = build_mbr([(part_start, part_size, 0x83, True)])

    with open(output, "wb") as f:
        f.seek(image_size - 1)
        f.write(b"\x00")
        write_at(f, 0, mbr_data)
        print("\n  Writing firmware ...")
        copy_file_at(f, fw_offset, firmware_path)
        print("  Writing ITB image ...")
        copy_file_at(f, itb_offset, itb_path)
        f.flush()

    final_size = os.path.getsize(output)
    print(f"\n  Firmware WIC created: {output} ({human_size(final_size)})")

    print()
    print("  SD Card Layout:")
    print("  +------------------------------------------------------------+")
    print(f"  | 0x{0:08X}  MBR (512 bytes)                              |")
    print(f"  | 0x{fw_offset:08X}  firmware ({human_size(fw_size):>10s})                    |")
    print(f"  | 0x{itb_offset:08X}  ITB image ({human_size(itb_size):>10s})                 |")
    print(f"  | 0x{part_start:08X}  Partition 1 ({human_size(part_size):>10s})                 |")
    print(f"  | 0x{image_size:08X}  End ({human_size(image_size):>10s})                       |")
    print("  +------------------------------------------------------------+")

    _print_flash_instructions(output)


def _print_flash_instructions(wic_path):
    name = os.path.basename(wic_path)
    print()
    print("  Flash to SD card:")
    print("  -----------------")
    print(f"  Etcher : Open balenaEtcher -> Select '{name}' -> Select SD -> Flash")
    print(f"  Linux  : sudo dd if={name} of=/dev/sdX bs=1M conv=fsync status=progress")
    print(f"  Win32  : Use Win32DiskImager or Rufus (dd mode) to write '{name}'")
    print()
    print("  NOTE: This is a firmware-only WIC image.")
    print("        For full system installation, use flex-installer after flashing.")
    print()


# ─── CLI ─────────────────────────────────────────────────────────────────────

def parse_args():
    p = argparse.ArgumentParser(
        prog=TOOL_NAME,
        description="Create bootable firmware WIC images for NXP i.MX / Layerscape platforms.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Firmware naming convention:
  Layerscape (all versions):           firmware_<machine>_sdboot.img
  i.MX with lsdk24*/lsdk25*:          firmware_<machine>_sdboot.img
  i.MX with lsdk26* and later:        <machine>-sd-flash.bin
  i.MX with before lsdk24*:           NOT SUPPORTED

Image composition rules:
  +---------------------+-----------+------------------------------+
  | Version             | Platform  | Files needed                 |
  +---------------------+-----------+------------------------------+
  | lsdk24* / lsdk25*   | i.MX      | firmware only (ITB included) |
  | lsdk26* and later   | i.MX      | firmware + ITB               |
  | all versions        | LS        | firmware only                |
  | before lsdk24*      | i.MX      | NOT SUPPORTED                |
  +---------------------+-----------+------------------------------+

Examples:
  # i.MX lsdk26*: auto-download flash.bin + ITB, create WIC
  python mkfw-wic.py -m imx8mpevk -v lsdk2606

  # i.MX lsdk25*: auto-download firmware only, create WIC (ITB included)
  python mkfw-wic.py -m imx8mpevk -v lsdk2512

  # Layerscape: auto-download firmware only, create WIC
  python mkfw-wic.py -m ls1046ardb -v lsdk2606

  # Use local files (i.MX lsdk26*)
  python mkfw-wic.py -m imx8mpevk -v lsdk2606 \\
      -f imx8mpevk-sd-flash.bin -t lsdk2606_poky_tiny_IMX_arm64.itb

  # Download only
  python mkfw-wic.py -m imx8mpevk -v lsdk2606 --download-only

  # List supported machines
  python mkfw-wic.py --list
""",
    )
    p.add_argument("-m", "--machine",
                   help="Target machine (e.g. imx8mpevk, ls1046ardb)")
    p.add_argument("-v", "--version", default=DEFAULT_VERSION,
                   help=f"SDK version (default: {DEFAULT_VERSION})")
    p.add_argument("-f", "--firmware", default="",
                   help="Local firmware file (skip download)")
    p.add_argument("-t", "--itb", default="",
                   help="Local ITB file for i.MX lsdk26*+ (skip download if needed)")
    p.add_argument("-o", "--output", default="",
                   help="Output WIC filename (auto-generated if omitted)")
    p.add_argument("-u", "--url", default="",
                   help=f"Base URL override (default: {DEFAULT_BASE_URL}/<version>)")
    p.add_argument("--itb-offset", default=hex(DEFAULT_ITB_OFFSET_KB),
                   help=f"ITB offset in 1K-blocks, hex or dec "
                        f"(default: 0x{DEFAULT_ITB_OFFSET_KB:X} = "
                        f"{DEFAULT_ITB_OFFSET_BYTES // MiB} MiB)")
    p.add_argument("--download-only", action="store_true",
                   help="Only download files, do not create WIC")
    p.add_argument("--list", action="store_true",
                   help="List supported machines and exit")
    p.add_argument("--version-info", action="version",
                   version=f"{TOOL_NAME} {TOOL_VERSION}")
    return p.parse_args()


def main():
    args = parse_args()

    # ── --list ──
    if args.list:
        print(f"\n{TOOL_NAME} - Firmware WIC Image Creator")
        print("=" * 50)
        print("\nSupported machines:")
        print(f"  Layerscape : {', '.join(LS_MACHINES)}")
        print(f"  i.MX       : {', '.join(IMX_MACHINES)}")
        print(f"\nDefault version: {DEFAULT_VERSION}")
        print(f"Download URL   : {DEFAULT_BASE_URL}/<version>/")
        print()
        print("Firmware naming convention:")
        print("  +---------------------+-----------+----------------------------------+")
        print("  | Version             | Platform  | Firmware filename                |")
        print("  +---------------------+-----------+----------------------------------+")
        print("  | lsdk24* / lsdk25*   | i.MX      | firmware_<machine>_sdboot.img    |")
        print("  | lsdk26* and later   | i.MX      | <machine>-sd-flash.bin           |")
        print("  | all versions        | LS        | firmware_<machine>_sdboot.img    |")
        print("  | before lsdk24*      | i.MX      | NOT SUPPORTED                    |")
        print("  +---------------------+-----------+----------------------------------+")
        print()
        print("Image composition rules:")
        print("  +---------------------+-----------+------------------------------+")
        print("  | Version             | Platform  | Files needed                 |")
        print("  +---------------------+-----------+------------------------------+")
        print("  | lsdk24* / lsdk25*   | i.MX      | firmware only (ITB included) |")
        print("  | lsdk26* and later   | i.MX      | firmware + ITB               |")
        print("  | all versions        | LS        | firmware only                |")
        print("  | before lsdk24*      | i.MX      | NOT SUPPORTED                |")
        print("  +---------------------+-----------+------------------------------+")
        print()
        return

    # ── Validate machine ──
    if not args.machine:
        print("ERROR: Please specify -m <machine>.  Use --list to see options.")
        sys.exit(1)

    machine = args.machine
    if machine not in ALL_MACHINES:
        print(f"ERROR: Unknown machine '{machine}'.")
        print(f"  Layerscape : {', '.join(LS_MACHINES)}")
        print(f"  i.MX       : {', '.join(IMX_MACHINES)}")
        sys.exit(1)

    version = args.version
    
    # ── Check i.MX version support (MUST be before any version-dependent logic) ──
    check_imx_version_support(machine, version)
    
    base_url = args.url if args.url else f"{DEFAULT_BASE_URL}/{version}"

    # Parse ITB offset
    try:
        itb_offset_kb = int(args.itb_offset, 0)
    except ValueError:
        print(f"ERROR: Invalid --itb-offset value: {args.itb_offset}")
        sys.exit(1)
    itb_offset_bytes = itb_offset_kb * KiB

    ls = is_layerscape(machine)
    need_itb = needs_separate_itb(machine, version)

    # ── Resolve filenames ──
    fw_name  = firmware_filename(machine, version)
    itb_name = itb_filename(version) if need_itb else None

    fw_path  = args.firmware if args.firmware else fw_name
    itb_path = args.itb if args.itb else (itb_name if itb_name else "")

    # ── Display info ──
    platform = "Layerscape" if ls else "i.MX"
    mode = "firmware + ITB" if need_itb else "firmware only (ITB included)"

    print(f"\n  Machine : {machine}")
    print(f"  Version : {version}")
    print(f"  Platform: {platform}")
    print(f"  Mode    : {mode}")
    print(f"  Firmware: {fw_name}")
    if need_itb:
        print(f"  ITB     : {itb_name}")

    # ── Download if needed ──
    need_dl_fw  = not os.path.isfile(fw_path)
    need_dl_itb = need_itb and not os.path.isfile(itb_path)

    if need_dl_fw or need_dl_itb:
        print(f"\n  Download URL: {base_url}")

    if need_dl_fw:
        fw_url = f"{base_url}/{fw_name}"
        fw_path = fw_name
        download_file(fw_url, fw_path)

    if need_dl_itb:
        itb_url = f"{base_url}/{itb_name}"
        itb_path = itb_name
        download_file(itb_url, itb_path)

    if args.download_only:
        print("\n  Download complete (--download-only).  No WIC created.")
        return

    # ── Validate local files ──
    if not os.path.isfile(fw_path):
        print(f"ERROR: Firmware not found: {fw_path}")
        sys.exit(1)
    if need_itb and not os.path.isfile(itb_path):
        print(f"ERROR: ITB not found: {itb_path}")
        sys.exit(1)

    # ── Output name ──
    output = args.output if args.output else f"{machine}_{version}_fw.wic"

    # ── Create WIC ──
    if need_itb:
        create_wic_with_itb(fw_path, itb_path, machine, version,
                            output, itb_offset_bytes)
    else:
        create_wic_single(fw_path, machine, version, output)


if __name__ == "__main__":
    main()

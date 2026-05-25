#!/bin/bash
#
# Copyright 2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
# Flex Installer Wizard: An interactive wizard for assembling flex-installer parameters
#
# Author: Lyrix Liu <lyrix.liu@nxp.com>
#

set -e

export NEWT_COLORS=''
# Set UTF-8 encoding
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Declare associative array for route table
declare -A ROUTES=(
    [1]=step_init_prompt
    [2]=step_sdk_version
    [3]=step_board_type
    [4]=step_device_selection
    [5]=step_confirm_execute
)

# Global variables to store user selections
BACK_TITLE="flex-installer cmd Usage Wizard, Press Back/ESC to go back."
LSDK_VERSION=""
BOARD=""
DEVICE=""
FLEX_INSTALLER_PATH="./flex-installer"
WGET_FLEXINSTALLER="https://www.nxp.com/lgfiles/sdk/lsdk2606/flex-installer"
EXTERNAL_URL="https://www.nxp.com/lgfiles/sdk/"
LINK="$EXTERNAL_URL"

#==============================================================================
# Utility Functions
#==============================================================================

check_whiptail() {
    if ! command -v whiptail >/dev/null 2>&1; then
        echo "Error: 'whiptail' is not installed."
        echo "Please install it first:"
        echo "  sudo apt install whiptail"
        exit 1
    fi
}

# Declare compatibility associative array
declare -A COMPAT=(
    ["lsdk2412"]="imx8mpevk imx8mmevk imx93evk imx93frdm imx91frdm ls1028ardb ls1043ardb ls1046ardb lx2160ardb"
    ["lsdk2506"]="imx8mpevk imx8mpfrdm imx8mmevk imx93evk imx93frdm imx91evk imx91frdm ls1028ardb ls1043ardb ls1046ardb lx2160ardb"
    ["lsdk2512"]="imx8mmevk imx8mpevk imx8mpfrdm imx8qmmek imx91evk imx91frdm imx91sfrdm imx93evk imx93frdm imx95evk imx95frdm ls1028ardb ls1043ardb ls1046ardb lx2160ardb"
    ["lsdk2606"]="imx8mmevk imx8mpevk imx8mpfrdm imx8qmmek imx91evk imx91frdm imx91sfrdm imx93evk imx93frdm imx95-15x15-frdm imx95-15x15-evk imx95-19x19-frdm-pro imx95-19x19-evk ls1028ardb ls1043ardb ls1046ardb lx2160ardb"
)

declare -A BOARD_INFO=(
    ["imx8mpevk"]="i.MX 8M Plus EVK Board"
    ["imx8mpfrdm"]="i.MX 8M Plus FRDM Board"
    ["imx8mmevk"]="i.MX 8M Mini EVK Board"
    ["imx8qmmek"]="i.MX 8QuadMax MEK Board"
    ["imx93evk"]="i.MX 93 11x11 EVK Board"
    ["imx93frdm"]="i.MX 93 11x11 FRDM Board"
    ["imx91evk"]="i.MX 91 11x11 EVK Board"
    ["imx91frdm"]="i.MX 91 11x11 FRDM Board"
    ["imx91sfrdm"]="i.MX 91 11x11 SFRDM Board"
    ["imx95evk"]="i.MX 95 15x15 EVK Board"
    ["imx95frdm"]="i.MX 95 15x15 FRDM Board"
    ["imx95-15x15-frdm"]="i.MX 95 15x15 FRDM Board"
    ["imx95-15x15-evk"]="i.MX 95 15x15 EVK Board"
    ["imx95-19x19-frdm-pro"]="i.MX 95 19x19 FRDMPRO Board"
    ["imx95-19x19-evk"]="i.MX 95 19x19 EVK Board"
    ["ls1028ardb"]="LS1028A Reference Design Board"
    ["ls1043ardb"]="LS1043A Reference Design Board"
    ["ls1046ardb"]="LS1046A Reference Design Board"
    ["lx2160ardb"]="LX2160A Reference Design Board"
)

get_board_notes() {
    local board_name="$1"
    if [[ -n "${BOARD_INFO["$board_name"]}" ]]; then
        echo ": ${BOARD_INFO["$board_name"]}"
    else
        echo ""
    fi
}

# Check if flex-installer exists and has correct version
check_flex_installer() {
    # Check if flex-installer exists
    if [ ! -f "$FLEX_INSTALLER_PATH" ]; then
        whiptail --title "Error" --msgbox \
            "flex-installer not found in current directory.\n\nDownload the 2606 version of flex-installer? " \
            12 60
	if curl -I --connect-timeout 5 IMEOUT "$EXTERNAL_URL" >/dev/null 2>&1; then
            wget "$WGET_FLEXINSTALLER"
	else
	    echo "Cannot link to resources. Please check your network connection"
	fi
        return 1
    fi

    # Make it executable
    chmod +x "$FLEX_INSTALLER_PATH"

    # Get version info
    VERSION_OUTPUT=$("$FLEX_INSTALLER_PATH" -v 2>&1)
    if [ $? -ne 0 ]; then
        whiptail --title "Error" --msgbox \
            "Failed to execute flex-installer.\n\nDownload the latest
		    version:\nwget http://www.nxp.com/lgfiles/sdk/lsdk2606/flex-installer" \
            14 70
        return 1
    fi

    # Extract last string and last 4 digits for version comparison
    LAST_STRING=$(echo "$VERSION_OUTPUT" | awk '{print $NF}')
    VERSION_NUM=$(echo "$LAST_STRING" | grep -oE '[0-9]+')

    # Compare version (minimum required: lsdk2606 = 2606)
    if [ "$VERSION_NUM" -lt 2606 ]; then
        whiptail --title "Error" --msgbox \
            "flex-installer version is outdated.\n\nCurrent version: $VERSION_NUM\nMinimum required: lsdk2606\n\nDownload the latest version:\nwget http://www.nxp.com/lgfiles/sdk/lsdk2606/flex-installer" \
            16 70
        return 1
    fi

    return 0
}

storage_device_detection() {
    local devcount=0

    while IFS= read -r line; do
        # Skip if line contains /dev/sda or boot
        if echo "$line" | grep -qE "(/dev/sda|boot|nvme|scsi|sas|virtio|pcie|ata)"; then
            continue
        fi

        # Only process disk devices
        if echo "$line" | grep -q "disk"; then
            devcount=$((devcount + 1))
        fi
    done < <(lsblk -dpno NAME,SIZE,MODEL,TYPE,TRAN 2>/dev/null)

    if [ $devcount -eq 0 ]; then
        whiptail --title "Error" --msgbox \
            "\`lsblk\` command failed to find sutiable storage device.\n\nPlease ensure the target SD card is inserted for image burning." \
            12 60
        return 2 # return error
    fi

    return 0
}

# Step 1: Initial confirmation prompt
step_init_prompt() {
    if whiptail --title "Step 1: Preparation Check" --backtitle "$BACK_TITLE" \
        --no-button "Back" \
        --yesno "Please confirm the following before proceeding:\n\n    1.Target SD card is inserted for image burning.\n    2.Normal access to the external network.\n\nDo you want to continue?" \
        14 60; then
        if storage_device_detection; then
            STEP=$((STEP+1))
        else
            STEP=0
        fi
    else
        STEP=0
    fi
}

# Step 2: SDK version selection
step_sdk_version() {
    local choice
    if choice=$(whiptail --title "Step 2: Select SDK Version" --backtitle "$BACK_TITLE" \
        --cancel-button "Back" \
	--menu "Select NXP Debian Linux SDK release version(Different versions support different board types.):" \
        14 60 4 \
        "lsdk2412" ": Debian12, Kernel version lf-6.6.36" \
        "lsdk2506" ": Debian12, Kernel version lf-6.6.52" \
        "lsdk2512" ": Debian13, Kernel version lf-6.12.20" \
        "lsdk2606" ": Debian13, Kernel version lf-6.12.49" \
        3>&1 1>&2 2>&3
    ); then
        LSDK_VERSION="$choice"
        STEP=$((STEP+1))
    else
        STEP=$((STEP-1))
    fi
}

# Step 3: Board type selection (dynamic based on SDK version)
step_board_type() {
    local board_count=0
    local menu_items=()

    for board in ${COMPAT[$LSDK_VERSION]}; do
        # Add prefix to prevent whiptail from interpreting options starting with "-"
        local note
	note=$(get_board_notes $board)
        menu_items+=("$board" "$note")
        board_count=$((board_count + 1))
    done

    # Create menu arguments array
    local choice
    if choice=$(whiptail --title "Step 3: Select Board" --backtitle "$BACK_TITLE" \
        --cancel-button "Back" \
        --menu "Select the target board to flash:" \
        18 65 7 \
        "${menu_items[@]}" \
        3>&1 1>&2 2>&3
    ); then
        BOARD="$choice"
        STEP=$((STEP+1))
    else
        STEP=$((STEP-1))
    fi
}

# Step 4: Device selection (SD card)
step_device_selection() {
    # Get list of block devices (excluding system disk /dev/sda and boot partitions)
    # Using while loop to handle device list properly
    local device_count=0
    local menu_items=()

    while IFS= read -r line; do
        # Skip if line contains /dev/sda or boot
        if echo "$line" | grep -qE "(/dev/sda|boot|nvme|scsi|sas|virtio|pcie|ata)"; then
            continue
        fi

        # Only process disk devices
        if echo "$line" | grep -q "disk"; then
            # Parse device information
            local name size model type_ tran
            name=$(echo "$line" | awk '{print $1}')
            size=$(echo "$line" | awk '{print $2}')
            model=$(echo "$line" | awk '{print $3}')
            type_=$(echo "$line" | awk '{print $4}')
            tran=$(echo "$line" | awk '{print $5}')

            # Build descriptive label
            local label="$size"
            [ -n "$model" ] && [ "$model" != "-" ] && label="$label $model $tran $type_"

            menu_items+=("$name" "$label")
            device_count=$((device_count + 1))
        fi
    done < <(lsblk -dpno NAME,SIZE,MODEL,TYPE,TRAN 2>/dev/null)

    if [ $device_count -eq 0 ]; then
        whiptail --title "Error" --msgbox \
            "\`lsblk\` command failed to find sutiable storage device.\n\nPlease ensure the target SD card is inserted for image burning." \
            12 60
        STEP=0
        return
    fi

    # Build whiptail command with proper argument handling
    local choice
    if choice=$(whiptail --title "Step 4: Select Target Device" --backtitle "$BACK_TITLE" \
        --cancel-button "Back" \
        --menu "Select the SD card to flash (system disk /dev/sda and devices using nvme, scsi, sas, virtio, pcie, or ata transport types are excluded):" \
        18 60 $device_count \
        "${menu_items[@]}" \
        3>&1 1>&2 2>&3
    ); then
        DEVICE="$choice"
        STEP=$((STEP+1))
    else
        STEP=$((STEP-1))
    fi
}

# Step 5: Confirmation and execution
step_confirm_execute() {
    # Generate command preview
    CMD1="./flex-installer -i pf:$LSDK_VERSION -d $DEVICE"
    CMD2="./flex-installer -i auto:$LSDK_VERSION -d $DEVICE -m $BOARD"

    local choice
    if choice=$(whiptail --title "Step 5: Confirm Execution" --backtitle "$BACK_TITLE" \
        --cancel-button "Back" \
        --yes-button "Execute" --no-button "Back" \
        --yesno "Please review your selections:\n\n\
-  SDK Version: $LSDK_VERSION\n\
-  Board: $BOARD\n\
-  Device: $DEVICE\n\n\
Following commands will be executed(takes about 5-10 minutes):\n\n\
- $CMD1\n\
- $CMD2\n\n\
The target disk will be forcibly formatted by first cmd. Proceed with caution.\nSceond cmd will download required files (e.g. rootfs_"$LSDK_VERSION"_debian_base_arm64.tar.zst) to current directory. Existing files will be skipped.\n\nContinue?" \
        25 100\
        3>&1 1>&2 2>&3
    ); then
        # Execute first command
        "$FLEX_INSTALLER_PATH" -i pf:"$LSDK_VERSION" -d "$DEVICE" -F
        if [ $? -ne 0 ]; then
            whiptail --title "Error" --msgbox \
                "Command 1 failed: $CMD1" \
                10 60
            STEP=0
            return
        fi

        # Execute second command
        "$FLEX_INSTALLER_PATH" -i auto:"$LSDK_VERSION" -d "$DEVICE" -m "$BOARD"
        if [ $? -ne 0 ]; then
            whiptail --title "Error" --msgbox \
                "Command 2 failed: $CMD2" \
                10 60
            STEP=0
            return
        fi

        whiptail --title "End" --msgbox \
            "The wizard has ended. Check the log for details.\n\nFlashed information:\n- SDK: $LSDK_VERSION\n- Board: $BOARD\n- Device: $DEVICE" \
            14 60

        STEP=0
    else
        STEP=$((STEP-1))
    fi
}

#==============================================================================
# Main Loop
#==============================================================================
main() {
    check_whiptail

    if ! check_flex_installer; then
        exit 1
    fi

    STEP=1

    while true; do
        # Validate STEP is within valid range
        if [ -z "${ROUTES[$STEP]}" ]; then
            if [ "$STEP" -eq 0 ]; then
                exit 0
            else
                whiptail --title "Error" --backtitle "$BACK_TITLE" --msgbox \
                    "Invalid step number: $STEP" \
                    10 50
                exit 1
            fi
        fi

        # Execute the current step function
        "${ROUTES[$STEP]}"
    done
}

# Run main function
main

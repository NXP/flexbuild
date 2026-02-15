#!/bin/sh
#Copyright 2023-2026 NXP

export TIMING_FOLDER="/usr/local/timing/LA1224RDB_RevC"

# Check if timing folder exists on this board
if [ ! -d "$TIMING_FOLDER" ]; then
    echo "Error: Timing folder not found: $TIMING_FOLDER"
    echo "This board does not appear to be LA1224RDB RevC or timing files are missing."
    exit 0
fi

# Print starting message
echo "Starting firmware upgrade..."

# Set SPI multiplexer
$TIMING_FOLDER/SPI_MUX_SEL.sh LX2
sleep 0.1

# Run smartdriver setup
$TIMING_FOLDER/smartdriver_setup.sh

# Check device version
if sync_timing_driver_app -f $TIMING_FOLDER/check_deviceversion.txt | grep -q "Device Grade    = 0x42"; then
	# Execute smartdriver_fw_fplan_dload_GradeB.txt
	sync_timing_driver_app -f $TIMING_FOLDER/smartdriver_fw_fplan_dload_GradeB.txt
elif sync_timing_driver_app -f $TIMING_FOLDER/check_deviceversion.txt | grep -q "Device Grade    = 0x44"; then
	# Execute smartdriver_fw_fplan_dload_GradeD.txt
	sync_timing_driver_app -f $TIMING_FOLDER/smartdriver_fw_fplan_dload_GradeD.txt
else
	# Print error message if no appropriate frequency plan is found
	echo "Frequency plan not found."
	exit 1
fi

# Reset Guel
if $TIMING_FOLDER/reset_la1224_RevC.sh; then
	# Print completion message
	echo "Firmware upgrade completed successfully."
else
	# Print error message if reset script fails
	echo "Error: Reset script failed."
	exit 1
fi

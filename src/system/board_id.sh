#!/bin/bash

get_board_id() {
	local board_id="unknown"
	local machine_content="$1"

	if [ -z "$machine_content" ]; then
		if [ ! -f "/sys/devices/soc0/machine" ]; then
			echo "Error: No input and /sys/devices/soc0/machine not found!" >&2
			return 1
		fi
		machine_content=$(cat /sys/devices/soc0/machine)
	fi

	#echo $machine_content

	case "$machine_content" in
	    # NXP i.MX series
	    *"i.MX8MPlus FRDM"*)      board_id="imx8mpfrdm" ;;
	    *"i.MX8MPlus EVK"*)       board_id="imx8mpevk" ;;
	    *"i.MX8MM EVK"*)          board_id="imx8mmevk" ;;
	    *"i.MX8MN EVK"*)          board_id="imx8mnevk" ;;
	    *"i.MX8MQ EVK"*)          board_id="imx8mqevk" ;;
	    *"i.MX8QM MEK"*)          board_id="imx8qmmek" ;;
	    *"i.MX8QXP MEK"*)         board_id="imx8qxpmek" ;;
	    *"i.MX8ULP EVK"*)         board_id="imx8ulpevk" ;;
	    *"i.MX91 11X11 EVK"*)     board_id="imx91evk" ;;
	    *"i.MX91 11X11 FRDM"*)    board_id="imx91frdm" ;;
        *"FRDM-iMX91 Storm"*)     board_id="imx91frdmstorm" ;;
	    *"i.MX93 11X11 EVK"*)     board_id="imx93evk" ;;
	    *"i.MX93 11X11 FRDM"*)    board_id="imx93frdm" ;;
	    
	    # FSL QorIQ series
	    *"LS1012A FRWY"*)         board_id="ls1012afrwy" ;;
	    *"LS1012A QDS"*)          board_id="ls1012aqds" ;;
	    *"LS1012A RDB"*)          board_id="ls1012ardb" ;;
	    *"LS1028A RDB"*)          board_id="ls1028ardb" ;;
	    *"LS1028A QDS"*)          board_id="ls1028aqds" ;;
	    *"LS1043A RDB"*)          board_id="ls1043ardb" ;;
	    *"LS1043A QDS"*)          board_id="ls1043aqds" ;;
	    *"LS1046A RDB"*)          board_id="ls1046ardb" ;;
	    *"LS1046A QDS"*)          board_id="ls1046aqds" ;;
	    *"LS1046A FRWY"*)         board_id="ls1046afrwy" ;;
	    *"LS1088A RDB"*)          board_id="ls1088ardb" ;;
	    *"LS1088A QDS"*)          board_id="ls1088aqds" ;;
	    *"LS2088A RDB"*)          board_id="ls2088ardb" ;;
	    *"LS2088A QDS"*)          board_id="ls2088aqds" ;;
	    *"LX2160ARDB"*)           board_id="lx2160ardb" ;;
	    *"LX2160AQDS"*)           board_id="lx2160aqds" ;;
	    *"LX2162AQDS"*)           board_id="lx2162aqds" ;;
	    
	    # Default processing rules (smart conversion)
	    *)
		    local normalized=$(echo "$machine_content" | tr '[:upper:]' '[:lower:]' | tr -d ' .-')
		    if [[ "$normalized" =~ nxp(i\.mx[0-9a-z]+) ]]; then
			local soc_part="${BASH_REMATCH[1]}"
			if [[ "$normalized" =~ (evk|frdm|mek) ]]; then
			    board_id="${soc_part}${BASH_REMATCH[1]}"
			else
			    board_id="${soc_part}"
			fi
		    elif [[ "$normalized" =~ (ls|lx)([0-9]+[a-z]*) ]]; then
			local soc_part="${BASH_REMATCH[1]}${BASH_REMATCH[2]}"
			if [[ "$normalized" =~ (rdb|qds|frwy) ]]; then
			    board_id="${soc_part}${BASH_REMATCH[1]}"
			else
			    board_id="${soc_part}"
			fi
		    fi
		    ;;
	esac
	echo "$board_id"
	return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    get_board_id "$@"
fi

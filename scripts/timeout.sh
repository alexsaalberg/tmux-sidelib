#!/usr/bin/env bash

source sideapp.sh
source variables.sh

main() {
	local app_prefix=$1
	local mainpane=$2
	local sidepane=$3

	if ! pane_exists $mainpane; then	
		debug_to_file "timeout: on_timeout_mainpane_gone()"
		on_timeout_mainpane_gone $app_prefix $mainpane $sidepane
	elif ! pane_exists $sidepane; then
		debug_to_file "timeout: on_timeout_sidepane_gone()"
		on_timeout_sidepane_gone $app_prefix $mainpane $sidepane
	else
		if has_state_changed $app_prefix $mainpane $sidepane; then
			debug_to_file "timeout(new_state): on_state_changed()"
			on_state_changed $app_prefix $mainpane $sidepane
		else
			debug_to_file "timeout(same_state): on_timeout()"
			on_timeout $app_prefix $mainpane $sidepane
		fi
	fi
}

main $1 $2 $3 # a timeout has just occured

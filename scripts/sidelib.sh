#!/usr/bin/env bash -i

TIMEOUT_LENGTH="0"
PROMPT_VAR="$PS1"
PROMPT_VAR="${PROMPT_VAR@P}"
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $CURRENT_DIR/sideapp.sh # this file sources helpers.sh and callbacks.sh
source $CURRENT_DIR/variables.sh

main() {
	local thispane=$(get_active_pane)
	local mainpane=$(get_mainpane $APP_PREFIX $thispane)
	#echo "main thispane=$thispane mainpane=$mainpane"
	if [ $mainpane != "none" ]; then # if thispane is a sidepane, toggle its mainpane
		thispane=$mainpane
	fi
	
	toggle_sidepane $thispane
}

toggle_sidepane() {
	local mainpane=$1
	
	local app_prefix=$APP_PREFIX
	local sidepane=$(get_sidepane $app_prefix $mainpane)

	if [ $sidepane == "none" ]; then
		debug_echo "sidelib: on_new_sideapp()"
		on_new_sideapp $app_prefix $mainpane

	else #  designations already exist,
	     #+ (there was a sidepane at some point)
		if ! pane_exists $mainpane; then
			#echo "mainpane gone"
			debug_echo "sidelib: on_mainpane_gone()"
			on_mainpane_gone $app_prefix $mainpane $sidepane
		elif ! pane_exists $sidepane; then
			#echo "sidepane gone"
			debug_echo "sidelib: on_sidepane_gone()"
			on_sidepane_gone $app_prefix $mainpane $sidepane
		else
			if has_state_changed $app_prefix $mainpane $sidepane; then
				debug_echo "sidelib: on_state_changed()"
				on_state_changed $app_prefix $mainpane $sidepane
			else
				debug_echo "sidelib: on_repress()"
				on_repress $app_prefix $mainpane $sidepane
			fi
		fi
	fi
}

main

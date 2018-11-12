#!/bin/bash

TIMEOUT_LENGTH="0"

source sideapp.sh # this file sources helpers.sh and callbacks.sh

GLOBAL_PREFIX="side"

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
		if [ $TIMEOUT_LENGTH != "0" ]; then
			setup_timeout
		fi
		on_new_sideapp $app_prefix $mainpane

	else #  designations already exist,
	     #+ (there was a sidepane at some point)
		if ! pane_exists $mainpane; then
			#echo "mainpane gone"
			on_mainpane_gone $app_prefix $mainpane $sidepane
		elif ! pane_exists $sidepane; then
			#echo "sidepane gone"
			on_sidepane_gone $app_prefix $mainpane $sidepane
		else
			#echo "repress"
			on_repress $APP_PREFIX $mainpane $sidepane
		fi
	fi
}

setup_timeout() {
	tmux set-window-option monitor-silence $TIMEOUT_LENGTH	
	tmux set-option silence-action any
	current_session=$(tmux display-message -p "#{session_id}")
	tmux set-hook -t $current_session 'alert-silence' "run -b \"$CURRENT_DIR/timeout.sh\""
}

main

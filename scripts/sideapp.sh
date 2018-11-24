#!/usr/bin/env bash -i

source callbacks.sh
source tmux_shell_line.sh

TIMEOUT_LENGTH="5"
APP_PREFIX="note"

open_man_for_mainpane() {
	local app_prefix=$1
	local mainpane=$2
	local sidepane=$3

	local program=$(get_program_of_pane $mainpane)
	
	if [ "$program"=="bash" ]; then
		local shell_line=$(get_tmux_shell_line $mainpane)
		echo "_${shell_line}_"
	fi
}

on_new_sideapp() {
	local app_prefix=$1
	local mainpane=$2

	local program=$(get_program_of_pane $mainpane)

	local sidepane=$(tmux split-window -h -t $mainpane -P -F "#{pane_id}")

	open_man_for_mainpane $app_prefix $mainpane $sidepane

	set_timeout $app_prefix $mainpane $sidepane
	designate_panes $app_prefix $mainpane $sidepane
	tmux last-pane
}

on_timeout() {
	local app_prefix=$1
	local mainpane=$2
	local sidepane=$3

	tmux send-keys -t $mainpane "HELP"
	tmux send-keys -t $sidepane "ME"
}

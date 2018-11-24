#!/usr/bin/env bash -i

source callbacks.sh
source tmux_shell_line.sh

TIMEOUT_LENGTH="5"
APP_PREFIX="note"

close_man_for_pane() {
	local pane=$2

	tmux send-keys -t $pane "q"
}

open_man_for_mainpane() {
	local app_prefix=$1
	local mainpane=$2
	local sidepane=$3

	local program=$(get_program_of_pane $mainpane)
	
	if [ "$program"=="bash" ]; then
		local shell_line=$(get_tmux_shell_line $mainpane)

		set $shell_line > /dev/null
		program=$0
		last_arg=${@: -1}
		#echo $program
		#echo "$last_arg"
	fi

	# if the program starts with letters, (we don't want to do "man ./script.sh")
	if [[ "$program" =~ ^[a-zA-Z] ]]; then
		tmux send-keys -t $sidepane "man $program"
		tmux send-keys -t $sidepane Enter
		# if $last_arg isn't empty, search for it in the man page
		if [ ! -z "$last_arg" ]; then
			tmux send-keys -t $sidepane "/^ +$last_arg" # / is search, ^ is beginning of line, + is one or more chars
			tmux send-keys -t $sidepane Enter
		fi 
	fi

	tmux send-keys -t $sidepane "$program"

	set_sideapp_option $app_prefix "$mainpane-program" "$program"
	set_sideapp_option $app_prefix "$mainpane-last_arg" "$last_arg"
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

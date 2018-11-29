#!/usr/bin/env bash -i

# SIDE_MAN

source callbacks.sh
source tmux_shell_line.sh

TIMEOUT_LENGTH="5"
APP_PREFIX="man"

OPTION_PROGRAM="program"
OPTION_SHELL_LINE="shell_line"

close_man_for_pane() {
	local pane=$1

	tmux send-keys -t $pane "q"
	tmux send-keys -t $pane Enter 
}

open_man_for_mainpane() {
	local app_prefix=$1
	local mainpane=$2
	local sidepane=$3

	local program=$(get_sideapp_option $app_prefix "$OPTION_PROGRAM" "none")
	local shell_line=$(get_sideapp_option $app_prefix "$OPTION_SHELL_LINE" "none")

	if [[ "$program" == "bash" && "$shell_line" != "none" ]]; then
		local last_arg=""

		set $shell_line > /dev/null
		program=$1 

		# set last_arg if there are ANY args
		if [[ $# -gt 1 ]]; then 
			last_arg=${@: -1}
		fi
	fi

	# if the program starts with letters, (we don't want to do "man ./script.sh")
	if [[ -n "$program" && ! "$program" =~ ^\. ]]; then
		tmux send-keys -t $sidepane "man $program"
		tmux send-keys -t $sidepane Enter
		# if $last_arg isn't empty, search for it in the man page
		if [ -n "$last_arg" ]; then
			tmux send-keys -t $sidepane "/"
			tmux send-keys -t $sidepane "^ +$last_arg" # / is search, ^ is beginning of line, + is one or more chars
			tmux send-keys -t $sidepane Enter
		fi 
	else
		local unused="none"
		# tmux send-keys -t $sidepane "$program"
	fi
}

on_new_sideapp() {
	local app_prefix=$1
	local mainpane=$2

	local program=$(get_program_of_pane $mainpane)

	local sidepane=$(tmux split-window -h -t $mainpane -P -F "#{pane_id}")

	has_state_changed $app_prefix $mainpane $sidepane # will set program & shell_line options
	open_man_for_mainpane $app_prefix $mainpane $sidepane # will access program & shell_line options

	set_timeout $app_prefix $mainpane $sidepane
	designate_panes $app_prefix $mainpane $sidepane
	tmux last-pane
}

has_state_changed() {
	local app_prefix=$1
	local mainpane=$2
	local sidepane=$3

	debug_to_file "has_state_changed: $mainpane $sidepane"

	local program=$(get_program_of_pane $mainpane)
	local old_program=$(get_sideapp_option $app_prefix "$OPTION_PROGRAM" "none")

	set_sideapp_option $app_prefix "$OPTION_PROGRAM" "$program"

	debug_to_file "program: $program, old_program: $old_program"
	if [ "$program" == "bash" ]; then
		local shell_line=$(get_tmux_shell_line $mainpane)
		local old_shell_line=$(get_sideapp_option $app_prefix "$OPTION_SHELL_LINE" "none")

		set_sideapp_option $app_prefix "$OPTION_SHELL_LINE" "$shell_line"

		if [[ -z "$shell_line" ]]; then
			shell_line="none"
		fi

		debug_to_file "shell_line: $shell_line, old_shell_line: $old_shell_line"
		# if the shell line has changed, 
		# OR the shell line is the same, but the program changed

		if [ "$shell_line" != "$old_shell_line" ]; then
			debug_to_file "has_state_changed(bash): TRUE"
			return 0 # TRUE 
		else
			if [ "$program" != "$old_program" ]; then
				debug_to_file "has_state_changed(bash_program): TRUE"
				return 0 # TRUE
			else
				debug_to_file "has_state_changed(bash): FALSE"
				return 1 # FALSE 
			fi
		fi
	else
		if [ "$program" != "$old_program" ]; then
			debug_to_file "has_state_changed: TRUE"
			return 0 # TRUE
		else
			# program hasn't changed
			debug_to_file "has_state_changed: FALSE"
			return 1 # FALSE
		fi
	fi
}

on_state_changed() {
	local app_prefix=$1
	local mainpane=$2
	local sidepane=$3

	local program=$(get_sideapp_option $app_prefix "$OPTION_PROGRAM" "none")
	local shell_line=$(get_sideapp_option $app_prefix "$OPTION_SHELL_LINE" "none")

	close_man_for_pane $sidepane
	open_man_for_mainpane $app_prefix $mainpane $sidepane
}

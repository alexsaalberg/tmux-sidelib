#SIDE_NOTE
source $CURRENT_DIR/callbacks.sh

TIMEOUT_LENGTH="0"
APP_PREFIX="note"

OPTION_PROGRAM="program"

close_note_in_pane() {
	local app_prefix=$1
	local pane=$2
	local program=$2

	tmux send-keys -t $pane Escape
	tmux send-keys -t $pane "ZZ"
}

open_note_in_pane() {
	local app_prefix=$1
	local pane=$2
	local program=$3

	note_path="${HOME}/.note/$program.note"
	swap_path="${HOME}/.note/.$program.note.swp"

	if [ -f $swap_path ]; then
		rm $swap_path
	fi

	# If the note file doesn't exist, put a title in it
	if [ ! -f $note_path ]; then
		echo "$program notes" > $note_path
	fi

	tmux send-keys -t $pane "vim $note_path"
	tmux send-keys -t $pane Enter
	tmux send-keys -t $pane "GG" # go to end of file
	tmux send-keys -t $pane "o" # open on new line
}

save_note_in_pane() {
	local app_prefix=$1
	local pane=$2
	
	tmux send-keys -t $pane Escape
	tmux send-keys -t $pane ":"
	tmux send-keys -t $pane "w"
	tmux send-keys -t $pane Enter
	tmux send-keys -t $pane "i"
}

on_new_sideapp() {
	local app_prefix=$1
	local mainpane=$2

	# figure out which program $mainpane has, so a note can be opened of it
	local program=$(get_program_of_pane $mainpane)
	set_sideapp_option $app_prefix "OPTION_PROGRAM" "$program"

	local sidepane=$(tmux split-window -h -t $mainpane -P -F "#{pane_id}")

	open_note_in_pane $app_prefix $sidepane $program

	set_timeout $app_prefix $mainpane $sidepane
	designate_panes $app_prefix $mainpane $sidepane
	tmux last-pane
}

on_timeout() {
	local app_prefix=$1
	local mainpane=$2
	local sidepane=$3

	#local pid=$(get_pid $mainpane)
	#local leaf_pid=$(get_leaf_pid $pid)

	local program=$(get_program_of_pane $mainpane)
	local old_program=$(get_sideapp_option $app_prefix "$mainpane-program" "")

	if [ "$program" != "$old_program" ]; then
		close_note_in_pane $app_prefix $sidepane $old_program
		open_note_in_pane $app_prefix $sidepane $program

		set_sideapp_option $app_prefix "$mainpane-program" "$program"
	else
		save_note_in_pane $app_prefix $sidepane
	fi
}

on_repress() {
	local app_prefix=$1
	local mainpane=$2
	local sidepane=$3

	save_note_in_pane $app_prefix $sidepane
	close_pane $sidepane
	undesignate_panes $app_prefix $mainpane $sidepane
}

on_state_changed() {
	local app_prefix=$1
	local mainpane=$2
	local sidepane=$3

	local program=$(get_sideapp_option $app_prefix "$OPTION_PROGRAM" "none")

	save_note_in_pane $app_prefix $sidepane
	close_note_in_pane $app_prefix $sidepane
	open_note_in_pane $app_prefix $sidepane "$program"

}

has_state_changed() {
	local app_prefix=$1
	local mainpane=$2
	local sidepane=$3

	local program=$(get_program_of_pane $mainpane)
	local old_program=$(get_sideapp_option $app_prefix "$OPTION_PROGRAM" "none")

	set_sideapp_option $app_prefix "$OPTION_PROGRAM" "$program"

	debug_to_file "has_state_changed: program: '$program'"
	debug_to_file "has_state_changed: old_program: '$old_program'"

	if [ "$program" == "$old_program" ]; then
		# state has NOT changed
		debug_to_file "no state change"
		return 1 # FALSE
	else
		# state HAS changed
		return 0 # TRUE
	fi
}

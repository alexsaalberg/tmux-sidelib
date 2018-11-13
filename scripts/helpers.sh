debug_echo() {
	local str=$1

	#echo "DEBUG: $str"
}

### tmux option setting ###

get_tmux_option() ( 
	local option=$1
	local default_value=$2
	local option_value=$(tmux show-option -qv "$option")
	if [ -z "$option_value" ]; then
		echo "$default_value"
	else
		echo "$option_value"
	fi
)

set_tmux_option() {
	local option=$1
	local value=$2

	tmux set-option -q "$option" "$value"
}

unset_tmux_option() {
	local option=$1

	tmux set-option -u -q "$option" 
}

set_sideapp_option() {
	local app_prefix=$1
	local option=$2
	local value=$3

	local prefixed_option="@$GLOBAL_PREFIX-$app_prefix-$option"

	set_tmux_option $prefixed_option $value
}

unset_sideapp_option() {
	local app_prefix=$1
	local option=$2

	local prefixed_option="@$GLOBAL_PREFIX-$app_prefix-$option"

	unset_tmux_option $prefixed_option
}

get_sideapp_option() {
	local app_prefix=$1
	local option=$2
	local default_value=$3

	local prefixed_option="@$GLOBAL_PREFIX-$app_prefix-$option"
	echo $(get_tmux_option $prefixed_option $default_value) 
}

### pane designations ###

designate_panes() {
	local app_prefix=$1
	local mainpane=$2
	local sidepane=$3

	set_sideapp_option $app_prefix "${mainpane}has" $sidepane
	set_sideapp_option $app_prefix "${sidepane}helps" $mainpane
}

undesignate_panes() {
	local app_prefix=$1
	local mainpane=$2
	local sidepane=$3

	unset_sideapp_option $app_prefix "${mainpane}has"
	unset_sideapp_option $app_prefix "${sidepane}helps"
}

set_timeout() {
	local app_prefix=$1
	local mainpane=$2
	local sidepane=$3

	local session=$(get_current_session)

	tmux set-window-option monitor-silence $TIMEOUT_LENGTH
	tmux set-option silence-action any
	tmux set-hook -t $session 'alert-silence' "run -b \"$CURRENT_DIR/timeout_plexer.sh\""

	local timeout_script="$CURRENT_DIR/timeout.sh"
	local timeout_cmd="$timeout_script $app_prefix $mainpane $sidepane"
	debug_echo "set_timeout: $timeout_cmd"
	tmux set-option -a $TIMEOUT_CMDS_OPTION ";$timeout_cmd"
}

unset_timeout() {
	local app_prefix=$1
	local mainpane=$2
	local sidepane=$3

	local timeout_script="$CURRENT_DIR/timeout.sh"
	local timeout_cmd="$timeout_script $app_prefix $mainpane $sidepane"

	local script_list=$(get_tmux_option $TIMEOUT_CMDS_OPTION "")

	debug_echo "removing: $timeout_cmd"

	debug_echo "unset_before: $script_list"
	# removes the substring ";$timeout_cmd" from script_list
	script_list=${script_list/;$timeout_cmd/}
	debug_echo "unset_after: $script_list"

	set_tmux_option $TIMEOUT_CMDS_OPTION "$script_list"
	
	if [ $script_list=="" ]; then
		tmux set-window-option monitor-silence 0
	fi
}

get_mainpane() { 
	local app_prefix=$1
	local sidepane=$2

	local mainpane=$( get_sideapp_option "$app_prefix" "${sidepane}helps" "none" )
	echo $mainpane
}

get_sidepane() (
	local app_prefix=$1
	local mainpane=$2

	local sidepane=$(get_sideapp_option $app_prefix "${mainpane}has" "none")
	echo $sidepane
)

get_active_pane() (
	local pane=$(tmux display-message -p "#{pane_id}")
	echo $pane
)

get_current_session() {
	local session=$(tmux display-message -p "#{session_id}")
	echo $session
}

close_pane() {
	pane_id=$1

	tmux kill-pane -t "$pane_id"
}


pane_exists() {
	local pane_id=$1
	local result=$(tmux display-message -p -t $pane_id "#{pane_id}" 2>&1)
	
	#echo "pane_exists(): pane_id=$pane_id result=$result"
	if [ "$result" == "$pane_id" ]; then
		#echo "pane does exist"
		return 0 # TRUE
	else
		#echo "pane does NOT exist"
		return 1 # FALSE
	fi
}

### other helpers
get_pid() (
	local pane=$1
	
	local pid=$(tmux display-message -p "#{pane_pid}")
	echo $pid
)

get_leaf_pid() (
	local pid=$1
	
	local child_pid=$(pgrep -P $pid)
	if [ -z $child_pid ]; then
		echo $pid
	else
		echo $(get_leaf_pid $child_pid)
	fi
)

get_clean_program() (
	local program=$1

	if [ $program == "-bash" ]; then
		echo "bash"
	else
		echo $program
	fi
)

get_program_of_pid() (
	local pid=$1

	local program=$(ps -p $pid -o "comm=")
	local clean_program=$(get_clean_program $program)
	echo "$clean_program"
)

get_program_of_pane() (
	local pane=$1

	local pid=$(get_pid pane)
	pid=$(get_leaf_pid $pid)
	local program=$(get_program_of_pid $pid)
	echo $program
)

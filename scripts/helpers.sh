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

	echo "unset $option"
	tmux set-option -uq "$option" 
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

close_pane() {
	pane_id=$1

	tmux kill-pane -t "$pane_id"
}


pane_exists() {
	local pane_id=$1
	local result=$(tmux display-message -t $pane_id -p "#{pane_id}")

	if [ $result == pane_id ]; then
		return 1
	else
		return 0
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
	if [ -z child_pid ]; then
		echo $pid
	else
		echo $(get_leaf_pid $pid)
	fi
)

get_clean_program() (
	local program=$1

	if [ program == "-bash" ]; then
		echo "bash"
	else
		echo $program
	fi
)

get_program_of_pid() (
	local pid=$1

	local program=$(ps -p $pid -o "comm=")
	local clean_program=$(get_clean_program $program)
	echo $program
)

get_program_of_pane() (
	local pane=$1

	local pid=get_pid pane
	local program=$(get_program_of_pid $pid)
	echo $program
)

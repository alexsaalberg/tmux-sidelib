debug_echo() {
	local str="$1"

	#echo "DEBUG: $str"
	debug_to_file "$str"
}

debug_to_file() {
	local str="$1"

	#local date_str=$(date)

	#echo "${date_str}: $str" >> $CURRENT_DIR/debug_out
}

debug_state_print() {
	local str="$1"

	debug_to_file "$str"
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
	local value="$2"

	tmux set-option -q "$option" "$value"
}

unset_tmux_option() {
	local option=$1

	tmux set-option -u -q "$option" 
}

set_sideapp_option() {
	local app_prefix=$1
	local option=$2
	local value="$3"

	local prefixed_option="@$GLOBAL_PREFIX-$app_prefix-$option"

	set_tmux_option $prefixed_option "$value"
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
	local hook_command="run -b \"$CURRENT_DIR/timeout_plexer.sh\""

	#tmux set-hook -t $session 'alert-silence' "run -b \"$CURRENT_DIR/timeout_plexer.sh\""
	tmux set-hook -t $session 'alert-silence' "$hook_command"
	local timeout_script="$CURRENT_DIR/timeout.sh"
	local timeout_cmd="$timeout_script $app_prefix $mainpane $sidepane"

	tmux set-option -a $TIMEOUT_CMDS_OPTION ";$timeout_cmd"

	debug_echo "set_timeout: $TIMEOUT_LENGTH"
	debug_echo "set_timeout_cmd: $timeout_cmd"
	debug_echo "set_hook: $hook_command"
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
	
	if [ "$script_list"=="" ]; then
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

get_pane_dir() {
	local pane="$1"
	local pane_dir=$(tmux display-message -p -t $pane '#{pane_current_path}')
	echo "$pane_dir"
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
	local pane="$1"
	
	local pid=$(tmux display-message -t $pane -p "#{pane_pid}")
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

	local pid=$(get_pid $pane)
	debug_to_file "get_program_of_pane: pid=$pid"
	pid=$(get_leaf_pid $pid)
	debug_to_file "get_program_of_pane: leaf_pid=$pid"
	local program=$(get_program_of_pid $pid)
	echo $program
)

### shell_line
get_tmux_shell_line() {
	local mainpane=$1

	local pane_contents=$(tmux capture-pane -p -t "$mainpane")
	#pane_contents="$pane_contents "
	#echo "_*_${pane_contents}_*_" > pane_contents


	local prompt_var=$(tmux show-environment -g PS1)
	prompt_var="${prompt_var#PS1=}"
	debug_to_file "  shell_line prompt_var: '$prompt_var'" 

	# we expand /w and /W manually because they will otherwise not be expanded to the correct dirs
	prompt_var=$(expand_shell_line_dirs $mainpane "$prompt_var")

	# Expand the prompt_var (e.g. '\w \u$ ') to the actual prompt (e.g. '/Users/John/Desktop JohnPerson$ ')
	local prompt="${prompt_var@P}"
	debug_to_file "  shell_line prompt: '$prompt'" 

	# If the prompt ends in a space, tmux capture-pane fails to work properly.
	# (In this case it will not capture the space on the last line)
	# Using the -J option captures too many spaces (non just typed spaces)
	# Solution: If the prompt ends with a space, add a space to the pane-contents
	#			and later remove the last character from shell_line
	if [ "${prompt: -1}" == " " ]; then
		pane_contents="$pane_contents "
	fi

	# Get the most recent line that contains the users expanded shell prompt
	local prompt_and_contents=$(echo "$pane_contents" | grep "$prompt" | tail -n 1)

	# Remove the prompt so it's just the shell_line (everything after the $ typically) (e.g. 'ls -l')
	local shell_line="${prompt_and_contents#$prompt}" 

	# If the prompt ends with a space, remove the last space from the shell_line (see above)
	if [ "${prompt: -1}" == " " ]; then
		shell_line="${shell_line%' '}"
	fi

	debug_to_file "  shell_line line: '$shell_line'" 

	echo "$shell_line"
}

get_base_dir() {
	local full_dir="$1"
	local base_dir=$(basename "$full_dir")
	echo "$base_dir"
}

expand_shell_line_dirs() {
	local mainpane=$1
	local prompt_var="$2"

	local mainpane_pwd=$(get_pane_dir $mainpane)
	local mainpane_base_dir=$(get_base_dir "$mainpane_pwd")

	# replace all /w with full working dir
	prompt_var=${prompt_var//\\w/$mainpane_pwd}

	# replace all /W with base dir
	prompt_var=${prompt_var//\\W/$mainpane_base_dir}

	echo "$prompt_var"
}

GLOBAL_PREFIX="side"

### tmux option setting ###

get_tmux_option() {
	local option=$1
	local default_value=$2
	local option_value=$(tmux show-option -gqv "$option")
	if [ -z "$option_value" ]; then
		echo "$default_value"
	else
		echo "$option_value"
	fi
}

set_tmux_option() {
	local option=$1
	local value=$2

	tmux set-option -gq "$option" "$value"
}

unset_tmux_option() {
	local option=$1

	tmux set-option -u -gq "$option" 
}

set_sideapp_option() {
	local app_prefix=$1
	local option=$2
	local value=$3

	local prefixed_option="@$GLOBAL_PREFIX-$app_prefix-$option"

	set_option $prefixed_option $value
}

unset_sideapp_option() {
	local app_prefix=$1
	local option=$2

	local prefixed_option="@$GLOBAL_PREFIX-$app_prefix-$option"

	unset_option $prefixed_option
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

	local mainpane=$(get_sideapp_option $app_prefix "${pane_id}helps" "")
	echo $mainpane
}

get_sidepane() {
	local app_prefix=$1
	local mainpane=$2

	local sidepane=$(get_sideapp_option $app_prefix "${mainpane}has" "")
	echo $sidepane
}

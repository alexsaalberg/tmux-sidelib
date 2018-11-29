source helpers.sh

### normal ###
on_new_sideapp() {
	local app_prefix=$1
	local mainpane=$2

	local sidepane=$(tmux split-window -h -t $mainpane -P -F "#{pane_id}")

	designate_panes $app_prefix $mainpane $sidepane
	tmux last-pane
}

on_repress() {
	local app_prefix=$1
	local mainpane=$2
	local sidepane=$3

	unset_timeout $app_prefix $mainpane $sidepane
	close_pane $sidepane
	undesignate_panes $app_prefix $mainpane $sidepane
}

on_sidepane_gone() {
	local app_prefix=$1
	local mainpane=$2
	local sidepane=$3

	unset_timeout $app_prefix $mainpane $sidepane
	undesignate_panes $app_prefix $mainpane $sidepane
}
# returns nothing

on_mainpane_gone() {
	local app_prefix=$1
	local mainpane=$2
	local sidepane=$3

	unset_timeout $app_prefix $mainpane $sidepane
	undesignate_panes $app_prefix $mainpane $sidepane
}
# returns nothing

### timeouts ###
on_timeout() {
	local app_prefix=$1
	local mainpane=$2
	local sidepane=$3
}

on_timeout_sidepane_gone() {
	local app_prefix=$1
	local mainpane=$2
	local sidepane=$3

	on_sidepane_gone $app_prefix $mainpane $sidepane
}

on_timeout_mainpane_gone() {
	local app_prefix=$1
	local mainpane=$2
	local sidepane=$3

	on_mainpane_gone $app_prefix $mainpane $sidepane
}

### state changes ###
has_state_changed() {
	local app_prefix=$1
	local mainpane=$2
	local sidepane=$3

	# by default, say state has NOT changed
	return 1 # FALSE
}

on_state_changed() {
	local app_prefix=$1
	local mainpane=$2
	local sidepane=$3
}

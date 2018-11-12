source helpers.sh

### normal ###
on_new_sideapp() {
	local app_prefix=$1
	local mainpane=$2

	local sidepane=$(tmux split-window -t $mainpane)

	designate_panes $app_prefix $mainpane $sidepane
}

on_repress() {
	local app_prefix=$1
	local mainpane=$2
	local sidepane=$3

	close_pane $sidepane
	undesignate_panes $app_prefix $mainpane $sidepane
}

on_sidepane_gone() {
	local app_prefix=$1
	local mainpane=$2
	local sidepane=$3

	undesignate_panes $app_prefix $mainpane $sidepane
}
# returns nothing

on_mainpane_gone() {
	local app_prefix=$1
	local mainpane=$2
	local sidepane=$3

	#close_pane $sidepane
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

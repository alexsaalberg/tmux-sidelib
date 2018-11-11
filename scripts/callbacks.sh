source helpers.sh

### normal ###
on_new_sideapp() {
	local mainpane=$1
	local sidepane=$2
}

on_repress() {
	local mainpane=$1
	local sidepane=$2

	close_pane $sidepane
	undesignate_panes $APP_PREFIX $mainpane $sidepane
}

on_sidepane_gone() {
	local mainpane=$1
	local sidepane=$2

	undesignate_panes $APP_PREFIX $mainpane $sidepane
}
# returns nothing

on_mainpane_gone() {
	local mainpane=$1
	local sidepane=$2

	close_pane $sidepane
	undesignate_panes $APP_PREFIX $mainpane $sidepane
}
# returns nothing

### timeouts ###
on_timeout() {
	local mainpane=$1
	local sidepane=$2
}

on_timeout_sidepane_gone() {
	local mainpane=$1
	local sidepane=$2

	on_sidepane_gone $mainpane $sidepane
}

on_timeout_mainpane_gone() {
	local mainpane=$1
	local sidepane=$2

	on_mainpane_gone $mainpane $sidepane
}

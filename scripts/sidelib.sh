source callbacks.sh # this file sources helpers.sh

main() {
	local thispane=$1	
	local mainpane=$(get_mainpane $APP_PREFIX $thispane)
	if [[ mainpane != ""]]; then
		thispane=mainpane
	fi
	
	toggle_sidepane $thispane
}

toggle_sidepane() {
	local mainpane=$1
	
	local sidepane=$(get_sidepane $APP_PREFIX $mainpane)
	if [[ sidepane != "" ]]; then
		new_sideapp $mainpane
	else
		on_repress $mainpane $sidepane
	fi
}

new_sideapp() {
	local mainpane=$1

	local sidepane=$(tmux split-window -t $mainpane)
	designate_panes $APP_PREFIX $mainpane $sidepane

	on_new_sideapp $mainpane $sidepane
}





main

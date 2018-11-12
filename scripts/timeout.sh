source sideapp.sh

main() {
	local mainpane=$1
	local sidepane=$2
	local app_prefix=$APP_PREFIX

	if ! pane_exists $mainpane; then	
		on_timeout_mainpane_gone $app_prefix $mainpane $sidepane
	elif ! pane_exists $sidepane; then
		on_timeout_sidepane_gone $app_prefix $mainpane $sidepane
	else
		on_timeout $app_prefix $mainpane $sidepane
	fi
}

main $1 $2 # a timeout has just occured

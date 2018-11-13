source sideapp.sh
source variables.sh

main() {
	local app_prefix=$1
	local mainpane=$2
	local sidepane=$3

	if ! pane_exists $mainpane; then	
		on_timeout_mainpane_gone $app_prefix $mainpane $sidepane
	elif ! pane_exists $sidepane; then
		on_timeout_sidepane_gone $app_prefix $mainpane $sidepane
	else
		on_timeout $app_prefix $mainpane $sidepane
	fi
}

main $1 $2 $3 # a timeout has just occured

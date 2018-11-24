source callbacks.sh

TIMEOUT_LENGTH="15"
APP_PREFIX="note"

on_new_sideapp() {
	local app_prefix=$1
	local mainpane=$2

	local sidepane=$(tmux split-window -h -t $mainpane -P -F "#{pane_id}")
	#echo "new sidepane=$sidepane"
	#echo "on_new mainpane=$mainpane sidepane=$sidepane prefix=$app_prefix"

	set_timeout $app_prefix $mainpane $sidepane

	designate_panes $app_prefix $mainpane $sidepane
	tmux last-pane
}

on_timeout() {
	local app_prefix=$1
	local mainpane=$2
	local sidepane=$3

	tmux send-keys -t $mainpane "HELP"
	tmux send-keys -t $sidepane "ME"
}

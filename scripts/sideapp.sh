source callbacks.sh

APP_PREFIX="example"

on_new_sideapp() {
	local app_prefix=$1
	local mainpane=$2

	local sidepane=$(tmux split-window -h -t $mainpane -P -F "#{pane_id}")

	designate_panes $app_prefix $mainpane $sidepane
	tmux last-pane
}

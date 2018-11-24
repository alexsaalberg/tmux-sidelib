get_tmux_shell_line() {
	local mainpane=$1

	local pane_contents=$(tmux capture-pane -p -t "$mainpane")

	# set in sidelib.sh
	local prompt_var=$(tmux show-environment -g PS1)
	prompt_var=${prompt_var#PS1=} # remove variable part

	local prompt=${prompt_var@P}

	# get the last line of the $pane_contents which contains $prompt
	local prompt_and_contents="$(echo "$pane_contents" | grep "$prompt" | tail -n 1)"

	#strip $prompt from $prompt_and_contents
	local bash_contents=${prompt_and_contents#$prompt}

	echo $bash_contents
}

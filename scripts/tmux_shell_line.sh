get_tmux_shell_line() {
	local mainpane=$1

	local pane_contents=$(tmux capture-pane -p -t "$mainpane")

	# set in sidelib.sh
	local prompt_var=$(tmux show-environment -g PS1)
	prompt_var=${prompt_var#PS1=} # remove variable part
	echo "ps1=$prompt_var" >> prog

	# we need to manually expand dir things (/w /W) or else they will expand to the dir of the running script
	prompt_var=$(expand_shell_line_dirs $mainpane "$prompt_var")
	echo "ps1=$prompt_var" >> prog

	# use @p to expand the variable
	local prompt=${prompt_var@P}
	echo "prompt=$prompt" >> prog

	echo "$pane_contents" > pane_contents
	# get the last line of the $pane_contents which contains $prompt
	local prompt_and_contents="$(echo "$pane_contents" | grep "$prompt" | tail -n 1)"

	#stri#p $prompt from $prompt_and_contents
	local bash_contents=${prompt_and_contents#$prompt}

	echo $bash_contents
}

get_pane_dir() {
	local pane="$1"
	local pane_dir=$(tmux display-message -p -t $pane '#{pane_current_path}')
	echo "$pane_dir"
}

expand_shell_line_dirs() {
	local mainpane="$1"
	local prompt_var="$2"
	
	local mainpane_pwd=$(get_pane_dir $mainpane)
	local mainpane_base_dir=$(basename "$mainpane_pwd")

	echo "pwd: $mainpane_pwd, base: $mainpane_base_dir" >> prog
	echo "prompt_varb4: $prompt_var" >> prog
	prompt_var=${prompt_var//\\W/$mainpane_base_dir}
	echo "prompt_vara5: $prompt_var" >> prog
	
	echo "$prompt_var"
}

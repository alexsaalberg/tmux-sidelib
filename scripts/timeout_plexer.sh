#!/usr/bin/env bash

source variables.sh
source helpers.sh

main() {
	local cmd_list=$(get_tmux_option $TIMEOUT_CMDS_OPTION "")

	local IFS=$';'
 	#  timeout scripts require arguments (and thus spaces),
	#+ so we separate between them with semicolons instead
	for cmd in $cmd_list
	do
		debug_echo "plexer: $cmd"
		eval "$cmd"
	done
}

main
exit 0

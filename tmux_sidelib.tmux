#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
tmux bind-key N run-shell -b "$CURRENT_DIR/scripts/sidelib.sh" 

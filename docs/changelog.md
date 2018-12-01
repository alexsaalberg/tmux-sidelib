# Releases

## v0.2

- Added more state change callbacks
  - `has_state_changed()`
    - Called when prefix is hit when sideapp is already running, or when a timeout has occurred
    - Returns `TRUE` or `FALSE`
      - If `TRUE`, sidelib will then call `on_state_changed()`
      - If `FALSE`, sidelib will then call `on_repress()` or `on_timeout()`, respectively.
    - The sideapp can also use this time to save information about the state (for example the current mainpane program).
  - `on_state_changed()`
    - Called after sidelib is activated if the state has changed.

- Fixed some functions in `helpers.sh`
  - Functions relating to `get_program_of_pane()`.
    
- Added more functions to `helpers.sh`
  - **`get_pane_dir()`**
    - Returns the directory of the pane who's id is passed in
  - **`get_tmux_shell_line()`**
    - Should only be called on a pane whose active program is a shell
    - Returns the shell_line of the pane (the stuff after the $)
  - `get_base_dir()`
    - Returns the base dir of a file path
  - `expand_shell_line_dirs()`
    - Used by `get_tmux_shell_line()`
    - Manually expands the /w and /W variables.  

## v0.1

- Initial release
- Support for creating sideapps through callbacks:
  - `on_new_sideapp()`, `on_repress()`, `on_sidepane_gone()`, `on_mainpane_gone()`
- Support for running callbacks on timeouts (after `x` seconds of no activity):
  - `on_timeout()`, `on_timeout_sidepane_gone()`, `on_timeout_mainpane_gone()` 

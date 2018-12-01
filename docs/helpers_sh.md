Usage and descriptions of the functions in `helpers.sh`

**Bolded** functions are expected to be used in sideapps, _unbolded_ functions are expected to only be used by sidelib itself. 

(Feel free to use what you want though).

### tmux options
- get_tmux_option()
  - Use: `local result=$(get_tmux_option $app_prefix $option $default_value)`
- set_tmux_option()
  - Use: `set_tmux_option=$app_prefix $option $value`
- unset_tmux_option()
  - Use: `unset_tmux_option $app_prefix $option`
- **set_sideapp_option()**
  - Use: `set_sideapp_option $app_prefix $option $value`
- **get_sideapp_option()**
  - Use: `local result=$(get_sideapp_option $app_prefix $option $default_value)`

### panes
- **designate_panes()**
  - Use: `designate_panes $app_prefix $mainpane $sidepane`
  - Sets relevant tmux user options to designate $sidepane and $mainpane as a pair.
- **undesignate_panes()**
  - Use: `undesignate_panes $app_prefix $mainpane $sidepane`
  - Description: Unsets relevant tmux user options to designate $sidepane and $mainpane as a pair.
- get_mainpane()
  - Use: `local sidepane=$(get_mainpane $app_prefix $sidepane)`
  - Retrieves the id of the $mainpane this $sidepane helps. **If no pane exists, returns** `none`
- get_sidepane()
  - **Use**: `local mainpane=$(get_mainpane $app_prefix $sidepane)`
  - **Description**: Retrieves the id of the $sidepane this $sidepane helps. **If no pane exists, returns** `none`
- **get_active_pane()**
  - Use: `local pane=$(get_active_pane)
  - Returns the id of the currently active pain. E.g. `%4`
- get_current_session()
  - Use: `local session=$(get_current_session)
- **close_pane()**
  - Use: `close_pane $pane
  - Closes the pane using `tmux kill-pane`
- **pane_exists()**
  - Use: `if pane_exists $pane; then`
  - Returns 0 if pane exists, 1 if it does NOT exist.
  - Only function to return a value (not a string onto stdout)

### timeouts
- **set_timeout()**
  - Use: `set_timeout $app_prefix $mainpane $sidepane`
- **unset_timeout()**
  - Use: `unset_timeout $app_prefix $mainpane $sidepane`

### Other

- get_pid()
  - Use: `local pid=$(get_pid $pane)`
- get_leaf_pid()
  - Use: `local leaf_pid=$(get_leaf_pid $pid)
  - Description: Recursively gets the child pid of $pid until it reaches a leaf.
  - E.g. If `vim` (pid `403`) was launched from `bash` (pid `301`), 
    - then `local pid=$(get_leaf_pid "301")` will result in pid=`"403"`
- get_clean_program()
  - Use: `local clean_program=$(get_clean_program $program)
  - Cleans excess characters from a program name.
    - Currently only changes `-bash` to `bash
- get_program_of_pid()
  - Use: `local program=$(get_program_of_pid $pid)
- **get_program_of_pane()**
  - Use: `local program=$(get_program_of_pane $pane)


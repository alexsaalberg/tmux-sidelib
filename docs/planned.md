# Planned Stuff

## v0.2
- Make state of sideapp part of sidelib proper
  - Problem: Currently the `note` and `man` apps have to build and test state on each timeout to see if any action should be taken
    - This results in duplicated and messy code.
  - Solution: Add a callback related to the sideapps state
    - Description
      - Will be called when prefix is repressed *and* when timeout occurs
      - Two possibilities:
        - `get_sideapp_state()`: Returns a string, representing the state of the sideapp
        - `is_state_changed()`: Returns 0 or 1, if the state has changed or not
    - Mechanics
      - If state is the same... 
        - on repress -> activate callback: `on_repress()`
        - on timeout -> do nothing
      - If state is different...
        - on repress -> activate callback: `on_state_changed()`
        - on timeout -> activate callback: `on_state_changed()`
- Add a second sidelib prefix
  - Problem: Timeout callbacks are slow and sort-of annoying and repress callbacks (while quicker) can close the sidepane.
  - Solution: Add a second prefix key
    - Possibilities
      - The second key will simply activate the `on_timeout()` callback
      - The second key will simply close the sidepane (so `on_repress()` can be used to quickly interact with the sideapp)
      - The second key will activate a `on_second()` callback
        - It cannot be used to make new sideapps
        - If either pane is closed, call the appropriate normal callbacks.
        - This way `on_second()` can call `on_timeout()` or `on_repress()` on it's own.

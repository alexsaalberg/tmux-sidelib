# Releases

## v0.1

- Initial release
- Support for creating sideapps through callbacks:
  - `on_new_sideapp()`, `on_repress()`, `on_sidepane_gone()`, `on_mainpane_gone()`
- Support for running callbacks on timeouts (after `x` seconds of no activity):
  - `on_timeout()`, `on_timeout_sidepane_gone()`, `on_timeout_mainpane_gone()` 

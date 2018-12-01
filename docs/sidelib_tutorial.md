
# How to use tmux-sidelib

This document is a walkthrough on how to make your own sideapp using tmux-sidelib.

Check out the [/demos](/demos) folder for some examples.

## Table Of Contents

- [How tmux-sidelib works](#how-tmux-sidelib-works)

- [How to write a sideapp](#how-to-write-a-sideapp)

## How tmux-sidelib works

Here's some examples of how sidelib works.

Most later examples continue from the state of the sideapp at the end of the first example.

**The user hits the prefix on a fresh tmux session.**

1. prefix is activated on pane `%0` (the pane with id 0).

2. Because pane `%0` is not registered as being a sidepane or a mainpane, sidelib activates teh callback `on_new_sideapp()` 

3. `on_new_sideapp()` splits pane `%0` and creates pane `%1`

4. The sideapp calls `designate_panes %0 %1` which notes that pane `%1` is the helper pane for `%0` and visa-versa.

From this situation a few things could happen, let's go over them.

**User closes sidepane, then activates prefix (Continuing from end of first example)**

1. User closes pane `%1`

2. prefix is activated when pane `%0` is active.

3. sidelib activates the callback `on_sidepane_gone()`. If not overridden this callback will...

    - Undesignate `%0` and `%1` as being paired.
  
    - Unset the timeout for this sideapp.
    
**User closes mainpane, then activates prefix (Continuing from end of first example)**

1. User closes pane `%0`

2. prefix is activated when pane `%1` is active.

3. sidelib activates the callback `on_mainpane_gone()`. If not overridden this callback will...

    - Undesignate `%0` and `%1` as being paired.
  
    - Unset the timeout for this sideapp.

**User does nothing, then activates prefix**

1. prefix is activated when pane `%1` or pane `%0` is active.

2. sidelib activates the callback `has_state_changed()`. If not overridden this callback will return `FALSE` (indicating state has not changed).

3. If `has_state_changed()` returned `FALSE`, then sidelib activates the callback `on_repress()`. 

   If not overriden this callback will...

    - Undesignate `%0` and `%1` as being paired.
    
    - Close pane `%1`
  
    - Unset the timeout for this sideapp.
   
3. If `has_state_changed()` returned `TRUE`, then sidelib activates the callback `on_state_changed()`. 

   If not overriden this callback will...

    - Do nothing
    
   Although it doesn't make sense to override `has_state_changed()` and not also `on_state_changed`


## How to write a sideapp

First, open a new file, called `sideapp.sh`, in [/scripts](/scripts).

Alternatively, copy [/demos/default/sideapp.sh](/demos/default/sideapp.sh) into [/scripts](/scripts). This file provides a nice starting point for a sideapp.

### 1. Necessary boilerplate

There's a couple thing that every sideapp needs to do to get sidelib to work properly.

1. **Add this line near the top of the `sideapp.sh`.**

       source $CURRENT_DIR/callbacks.sh
   
   `callback.sh` itself sources `helpers.sh`, so this line is required for sidelib to function.
   
   Notice the `$CURRENT_DIR/`. If you want to use any other files for your sideapp make sure to source them the same way (relative to the CURRENT_DIR variable). (If you don't they will be sourced relative to the root directory).
 
2. **Set the `APP_PREFIX` variable**

       APP_PREFIX="app_name"
   
   Your app prefix cannot contain any whitespace characters and generally should be short. Examples are "note' and "man" in /demos.
   
That's all that's necessary, But if you don't override any callback functions your app won't do anything.
   
### 2. on_new_sideapp()

This callback is activated when your sideapp first starts.

At a bare minimum, it should split the mainpane and designate a sidepane.

This can be done using `tmux split-window` and the `helpers.sh` function `designate_panes()`

Here's an example. See the [tmux man page](https://man.openbsd.org/OpenBSD-current/man1/tmux.1#split-window) for more info about split-window.

    local sidepane=$(tmux split-window -h -t $mainpane -P -F "#{pane_id}")
    designate_panes $mainpane $sidepane
  
The `-P -F "#{pane_id}"` is crucial. It outputs the new pane's id into stdout, which is then stored in `sidepane`.

Once the sidepane is created you'll want to do something with the sidepane. 

For example, to call ls you might do this. (You can also pass a command directly when you use split-window).

    tmux send-keys -t $sidepane "ls"
    tmux send-keys -t $sidepane Enter

### 3. has_state_changed() and on_state_changed()

At this point the sideapp is fully functional. If you chose to not extend it at all it will simply exit (close the sidepane) when reactivated.

If you wish extend the functionality look into the [other callback functions](docs/callbacks.md).

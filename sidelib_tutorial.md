# How to use tmux-sidelib

This document is a walkthrough on how to make your own sideapp using tmux-sidelib.

Check out the [/demos](/demos) folder for some examples.

## 1. Necessary boilerplate

There's a couple thing that every sideapp needs to do to get sidelib to work properly.

1. **Add this line near the top of the file.**

       source $CURRENT_DIR/callbacks.sh
   
   `callback.sh` itself sources `helpers.sh`, so this line is required for sidelib to function.
   
   Notice the `$CURRENT_DIR/`. If you want to use any other files for your sideapp make sure to source them the same way (relative to the CURRENT_DIR variable).
 
2. **Set the `APP_PREFIX` variable**

       APP_PREFIX="app_name"
   
   Your app prefix cannot contain any whitespace characters and generally should be short. Examples are "note' and "man" in /demos.
   
That's all that's necessary, But if you don't override any callback functions your app won't do anything.
   
## on_new_sideapp



### Split the mainpane

The most complex task that the sideapp is in charge of is creating the sidepane.

Here's an example. See the [tmux man page](https://man.openbsd.org/OpenBSD-current/man1/tmux.1#split-window) for more info.

    local sidepane=$(tmux split-window -h -t $mainpane -P -F "#{pane_id}")
  
The `-P -F "#{pane_id}"` is crucial. It outputs the new pane's id into stdout, which is then stored in `sidepane`.

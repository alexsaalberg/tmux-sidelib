# Tmux Sidelib


## Description

Tmux Sidelib is a bash script library meant to reduce the redundant work required to create tmux-plugins such as [tmux-sidelib](https://github.com/tmux-plugins/tmux-sidebar) or [tmux-notepane](https://github.com/alexsaalberg/tmux-notepane). These are plugins which open a useful program when activated via a tmux binding.

## How to use

#### Use an example sideapp

1. Clone the repo

2. Copy a demo `sideapp.sh` program from [/demos](/demos) into [/scripts](/scripts).

       cp /demos/note/sideapp.sh /scripts

3. Enter tmux if you are not already

       tmux

4. Run `tmux_sidelib.tmux` (it's a shell script)

       ./tmux_sidelib.tmux
    
4. Hit P-N (Prefix + N)

#### Create your own sideapp

- [Sidelib Tutorial](/docs/sidelib_tutorial.md)

- [`helpers.sh` documentation](/docs/helpers_sh.md)

## Examples of "sideapps"

- [tmux-sideman](https://www.github.com/alexsaalberg/tmux-sideman)

## Updates

- [changelog](/docs/changelog.md) 

- [planned](/docs/planned.md)

## Requirements

- `tmux 1.8` or higher

## Other Stuff

- [bash notes](/docs/bash_notes.md)

- [tmux-sidebar](tmux-plugins/tmux-sidebar)

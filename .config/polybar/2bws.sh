#!/usr/bin/env bash
# display workspace status
# requires wmctrl

# get the current workspace
ws=$( xprop -root _NET_CURRENT_DESKTOP | sed -e 's/_NET_CURRENT_DESKTOP(CARDINAL) = //' )

# icons

CURRENT=∙
OCCUPIED=∙
UNOCCUPIED=⋅

# colors
fg="#fcf529"
fg1="#CCffffff"

#  print workspaces to stdout
draw() {
    for i in {0..4}; do
        # get the number of windows in each workspace
        #windows=$( wmctrl -l | cut -d ' ' -f3 | grep $i | wc -l )

        if [[ $i -eq $ws ]]
        then
            # current workspace
            echo -ne "%{F$fg}  ●  "
        else
            echo -ne "%{F$fg1}  ●  "
        fi
    done
}

draw

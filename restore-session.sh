#!/bin/bash
 
# Wait for i3 to fully start
sleep 3
 
# Wait for i3 socket to be available
while ! i3-msg -t get_version &>/dev/null; do
    sleep 0.5
done
 
# Extra delay for safety (polybar, picom, etc. need to load)
sleep 2
 
RESURRECT_DIR=~/.i3/i3-resurrect
 
for layout_file in "$RESURRECT_DIR"/workspace_*_layout.json; do
    # Extract workspace name from filename
    ws=$(basename "$layout_file" | sed 's/workspace_//;s/_layout.json//')
 
    # Check that the programs file also exists
    prog_file="$RESURRECT_DIR/workspace_${ws}_programs.json"
    if [[ -f "$prog_file" ]]; then
        i3-resurrect restore -w "$ws" -n
    fi
done

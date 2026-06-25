#!/bin/bash

export I3SOCK=$(i3 --get-socketpath)

RESURRECT_DIR=~/.i3/i3-resurrect

# Rimuovi i file dei workspace non più aperti
active=$(i3-msg -t get_workspaces | jq -r '.[].name')
for layout_file in "$RESURRECT_DIR"/workspace_*_layout.json; do
    ws=$(basename "$layout_file" | sed 's/workspace_//;s/_layout.json//')
    if ! echo "$active" | grep -qx "$ws"; then
        rm -f "$RESURRECT_DIR/workspace_${ws}_layout.json" "$RESURRECT_DIR/workspace_${ws}_programs.json"
    fi
done

i3-msg -t get_workspaces | jq -r '.[].name' | while read ws; do
    i3-resurrect save -w "$ws"
done

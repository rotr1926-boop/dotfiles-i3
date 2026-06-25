#!/bin/bash
 
# Aspetta che i3 sia completamente avviato
sleep 3
 
# Aspetta che i3 socket sia disponibile
while ! i3-msg -t get_version &>/dev/null; do
    sleep 0.5
done
 
# Ulteriore delay per sicurezza (polybar, picom, ecc. devono caricarsi)
sleep 2
 
RESURRECT_DIR=~/.i3/i3-resurrect
 
for layout_file in "$RESURRECT_DIR"/workspace_*_layout.json; do
    # Estrai il nome del workspace dal filename
    ws=$(basename "$layout_file" | sed 's/workspace_//;s/_layout.json//')
 
    # Controlla che esista anche il file dei programmi
    prog_file="$RESURRECT_DIR/workspace_${ws}_programs.json"
    if [[ -f "$prog_file" ]]; then
        i3-resurrect restore -w "$ws" -n
    fi
done

#!/usr/bin/env bash
# Tokyo Night rofi clipboard picker
# Requires: rofi, cliphist, wl-clipboard

selected=$(cliphist list | rofi -dmenu -i -p "Clipboard" -theme ~/.config/rofi/clipboard.rasi)

[ -n "$selected" ] && echo "$selected" | cliphist decode | wl-copy

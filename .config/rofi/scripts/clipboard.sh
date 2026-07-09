#!/usr/bin/env bash
# Tokyo Night rofi clipboard picker with reset
# Requires: rofi, cliphist, wl-clipboard

# Add a "Reset" entry at the top, separated by a delimiter
selected=$(cliphist list | sed '1i\─── Reset Clipboard ───' | rofi -dmenu -i -p "Clipboard" -theme ~/.config/rofi/clipboard.rasi)

[ -z "$selected" ] && exit 0

if [ "$selected" = "─── Reset Clipboard ───" ]; then
  # Clear cliphist database
  rm -f ~/.cache/cliphist/db
  notify-send "Clipboard" "History cleared"
  exit 0
fi

echo "$selected" | cliphist decode | wl-copy

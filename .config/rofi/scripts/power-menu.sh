#!/usr/bin/env bash
# Tokyo Night rofi power menu
# Requires: rofi, systemd, swaylock (or your lock command)

options="⏻  Shutdown\n  Reboot\n  Lock\n󰤄  Suspend\n󰗽  Logout"

chosen=$(echo -e "$options" | rofi -dmenu -i -p "Power" -theme ~/.config/rofi/powermenu.rasi)

case "$chosen" in
    *Shutdown*) systemctl poweroff ;;
    *Reboot*)   systemctl reboot ;;
    *Lock*)     swaylock || loginctl lock-session ;;
    *Suspend*)  systemctl suspend ;;
    *Logout*)   niri msg action quit ;;
esac

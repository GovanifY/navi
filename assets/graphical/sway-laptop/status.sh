#!/bin/sh
# The Sway configuration file in ~/.config/sway/config calls this script.
# You should see changes to the status bar after saving this script.
# If not, do "killall swaybar" and $mod+Shift+c to reload the configuration.

# The abbreviated weekday (e.g., "Sat"), followed by the ISO-formatted date
# like 2018-10-06 and the time (e.g., 14:01)
date_formatted=$(date "+%a %d/%m/%Y %H:%M")

# Returns the battery status: "Full", "Discharging", or "Charging".
battery_status=$(cat /sys/class/power_supply/BAT/status)

mail=$(cat ~/.local/share/mail/unread)

battery_info=$(upower --show-info $(upower --enumerate |\
grep 'BAT') |\
egrep "state|percentage" | grep -oP '[0-9]*%') 

# Emojis and characters for the status bar
#     ⚡  \|
echo "mail: $mail | bat: $battery_info | $date_formatted"

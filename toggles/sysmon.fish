#!/bin/fish

. (dirname (status filename))/util.fish

spawn-client '.class == "btop" and .title == "btop" and .workspace.name == "special:sysmon"' foot -a 'btop' -T 'btop' -- btop

hyprctl dispatch togglespecialworkspace sysmon

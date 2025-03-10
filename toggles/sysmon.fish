#!/bin/fish

. (dirname (status filename))/util.fish

command -v foot-exec &> /dev/null && set -l cmd foot-exec || set -l cmd foot
spawn-client '.class == "btop" and .title == "btop" and .workspace.name == "special:sysmon"' $cmd -a 'btop' -T 'btop' -- btop

hyprctl dispatch togglespecialworkspace sysmon

#!/bin/fish

cd (dirname (realpath (status filename))) || exit

. ./util.fish

if test "$argv[1]" = shell
    if contains 'caelestia' (astal -l)
        if test -n "$argv[2..]"
            log "Sent command '$argv[2..]' to shell"
            astal -i caelestia $argv[2..]
        else
            warn 'No args given, ignoring'
        end
    else
        warn 'Shell unavailable'
    end
    exit
end

if test "$argv[1]" = toggle
    set -l valid_toggles communication music sysmon specialws
    contains "$argv[2]" $valid_toggles && ./toggles/$argv[2].fish || error "Invalid toggle: $argv[2]"
    exit
end

if test "$argv[1]" = workspace-action
    ./workspace-action.sh $argv[2..]
    exit
end

set valid_subcommands screenshot workspace-action \
    clipboard clipboard-delete emoji-picker \
    change-wallpaper pip

if contains "$argv[1]" $valid_subcommands
    ./$argv[1].fish $argv[2..]
    exit
end

test "$argv[1]" != help && error "Unknown command: $argv[1]"

echo 'Usage: caelestia COMMAND [ ...args ]'
echo
echo 'COMMAND := help | shell | workspace-action | change-wallpaper'
echo
echo '  help: show this help message'
echo '  shell: send a message to the shell'
echo '  screenshot: take a screenshot'
echo '  workspace-action: execute a Hyprland workspace dispatcher in the current group'
echo '  change-wallpaper: change the wallpaper'
echo '  pip: move the focused window into picture in picture mode or start the pip daemon'

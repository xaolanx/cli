#!/bin/fish

cd (dirname (status filename)) || exit

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

if test "$argv[1]" = change-wallpaper
    ./change-wallpaper.fish $argv[2..]
    exit
end

test "$argv[1]" != help && error "Unknown command: $argv[1]"

echo 'Usage: caelestia COMMAND'
echo
echo 'COMMAND := help | shell | change-wallpaper'
echo
echo '  help: show this help message'
echo '  shell: send a message to the shell'
echo '  change-wallpaper: change the wallpaper'

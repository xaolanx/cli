#!/bin/fish

cd (dirname (status filename)) || exit

. ./util.fish

if test "$argv[1]" = change-wallpaper
    ./change-wallpaper.fish $argv[2..]
end

test "$argv[1]" != help && error "Unknown command: $argv[1]"

echo 'Usage: caelestia COMMAND'
echo
echo 'COMMAND := help | change-wallpaper'
echo
echo '  help: show this help message'
echo '  change-wallpaper: change the wallpaper'

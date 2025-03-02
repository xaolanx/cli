#!/bin/fish

function nl-echo
    # Echo with newlines
    for a in $argv
        echo $a
    end
end

function light-theme
    set -g light_vals 50,10,16,22,34,46,59,69,78,85,97,94,90
    set -g colour_scheme light
end

function dark-theme
    set -g light_vals 70,90,75,63,52,42,32,26,20,16,12,9,6
    set -g colour_scheme dark
end

set -l src (dirname (status filename))

. $src/../util.fish

if test "$argv[1]" = --theme
    set theme $argv[2]
    set -e argv[1..2]
end

test -f "$argv[1]" && set -l img "$argv[1]" || set -l img $C_STATE/wallpaper/current
set -l img (realpath $img)

if set -q theme
    test "$theme" = light && light-theme || dark-theme
else
    # Light theme if background lighter than foreground
    set -l bg_fg ($src/getlightness.py (okolors $img -k 2 | string split ' '))
    test "$bg_fg[1]" -gt "$bg_fg[2]" && light-theme || dark-theme
end

echo -n $colour_scheme > $C_STATE/scheme/dynamic-mode.txt

# 2nd line except first element is the palette
# The first element in lines 3+ are the layers
set -l names rosewater flamingo pink mauve red maroon peach yellow green teal sky sapphire blue lavender text subtext1 subtext0 overlay2 overlay1 overlay0 surface2 surface1 surface0 base mantle crust success error
set -l colours ($src/autoadjust.py $colour_scheme (okolors $img -k 15 -w 0 -l $light_vals))

for i in (seq 1 (count $colours))
    echo "$names[$i] $colours[$i]"
end

set -l accent (okolors $img -k 4 | cut -d ' ' -f 4)
echo -n "accent $accent"

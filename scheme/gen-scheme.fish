#!/bin/fish

function nl-echo
    # Echo with newlines
    for a in $argv
        echo $a
    end
end

set -l src (dirname (status filename))

. $src/../util.fish

set -l colour_names rosewater flamingo pink mauve red maroon peach yellow green teal sky sapphire blue lavender
set -l layer_names text subtext1 subtext0 overlay2 overlay1 overlay0 surface2 surface1 surface0 base mantle crust

test -f "$argv[1]" && set -l img "$argv[1]" || set -l img $CACHE/wallpaper/current
set -l img (realpath $img)

# Light theme if background lighter than foreground
set -l bg_fg ($src/getlightness.py (okolors $img -k 2 | string split ' '))
if test "$bg_fg[1]" -gt "$bg_fg[2]"
    set light_vals 40,10,16,22,34,46,59,69,78,85,97,94,90
    set colour_scheme light
else
    set light_vals 70,90,75,63,52,42,32,26,20,16,12,9,6
    set colour_scheme dark
end

test "$(cat $CACHE/scheme/current.txt)" = dynamic && gsettings set org.gnome.desktop.interface color-scheme \'prefer-$colour_scheme\'

set -l colours_raw (okolors $img -k 15 -w 0 -l $light_vals)
set -l colours (string split ' ' $colours_raw[2])[2..]
set -l layers (nl-echo $colours_raw | cut -f 1 -d ' ')[3..]

for i in (seq 1 (count $colour_names))
    echo "$colour_names[$i] $colours[$i]"
end

for i in (seq 1 (count $layer_names))
    echo "$layer_names[$i] $layers[$i]"
end

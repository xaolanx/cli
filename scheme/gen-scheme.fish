#!/bin/fish

set -l src (dirname (status filename))

. $src/../util.fish

test -f "$argv[1]" && set -l img "$argv[1]" || set -l img $C_STATE/wallpaper/current
set -l img (realpath $img)
contains -- "$argv[2]" light dark && set -l theme $argv[2] || set -l theme dark

# Generate colours
test $theme = light && set -l lightness 50 || set -l lightness 70
$src/autoadjust.py $theme (okolors $img -k 14 -w 0 -l $lightness)

# Generate layers and accents
$src/genmaterial.py $img $theme | head -c -1  # Trim trailing newline

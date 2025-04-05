#!/bin/fish

set -l src (dirname (status filename))

. $src/../util.fish

test -f "$argv[1]" && set -l img (realpath "$argv[1]") || set -l img $C_STATE/wallpaper/thumbnail.jpg
contains -- "$argv[2]" light dark && set -l theme $argv[2] || set -l theme dark

set -l variants vibrant tonalspot expressive fidelity fruitsalad rainbow neutral content monochrome

# Generate colours
set -l colours ($src/score.py $img)
for variant in $variants
    mkdir -p $src/../data/schemes/dynamic/$variant
    $src/autoadjust.py $theme $variant $colours | head -c -1 > $src/../data/schemes/dynamic/$variant/$theme.txt
end
